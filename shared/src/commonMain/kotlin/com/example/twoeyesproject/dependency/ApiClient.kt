package com.example.twoeyesproject.dependency

// ApiClient.kt
import com.example.twoeyesproject.AppConstants
import com.example.twoeyesproject.platformspecific.PlatformSecureStorage
import com.example.twoeyesproject.platformspecific.platformHttpClient
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.mock.MockEngine
import io.ktor.client.engine.mock.respond
import io.ktor.client.plugins.HttpRequestRetry
import io.ktor.client.plugins.auth.Auth
import io.ktor.client.plugins.auth.providers.BearerTokens
import io.ktor.client.plugins.auth.providers.bearer
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.delete
import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.Headers
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.headersOf
import io.ktor.serialization.kotlinx.json.json
import io.ktor.utils.io.ByteReadChannel
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

// ── JSON 요청에 쓸 data class (Codable 과 같은 역할) ──────────────

@Serializable
data class AppleLoginRequest(
    val identityToken: String,
    val authorizationCode: String?,
    val fullName: AppleNameComponent?,
)
@Serializable
data class AppleNameComponent(
    val firstName: String?,
    val lastName: String?
)

@Serializable
data class GoogleLoginRequest(val idToken: String)

@Serializable
data class RefreshTokenRequest(val refreshToken: String)

@Serializable
data class AuthResponse(
    val accessToken: String,
    val refreshToken: String,
    val user: UserResponse
)

@Serializable
data class UserResponse(
    val id: String,
    val provider: String,
    val email: String? = null,
    val name: String? = null,
    val profileImage: String? = null
)

@Serializable
data class FeedResponse(
    val data: List<Data>,
    val meta: Meta
) {
    @Serializable
    data class Data(
        val id: String, val content: String?, val tags: List<String>,
        val likeCount: Int, val isLiked: Boolean, val user: User,
        val images: List<Image>, val createdAt: String, val updatedAt: String,
    )
    @Serializable
    data class User(
        val id: String, val name: String?, val profileImage: String?
    )
    @Serializable
    data class Image(
        val id: String, val url: String, val order: Int
    )
    @Serializable
    data class Meta(
        val total: Int, val page: Int, val limit: Int, val totalPages: Int,
    )
}

@Serializable
data class LikeResponse(
    val feedId: String, val likeCount: Int, val isLiked: Boolean
)

// ── 클라이언트 ─────────────────────────────────────────────────────

open class ApiClient {
    // lazy: Preview 환경에서 ApiClient 생성 시 PlatformSecureStorage(KoinComponent) 즉시 초기화를
    // 막기 위해 지연 초기화. 실제 인증 요청(401 응답 시 loadTokens 호출)이 일어날 때만 생성됨.
    private val secureStorage: PlatformSecureStorage by lazy { PlatformSecureStorage() }

    private val client = platformHttpClient().config {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true })
        }
        install(HttpRequestRetry) {
            retryOnServerErrors(maxRetries = 3)
            exponentialDelay()
        }
        install(Auth) {
            bearer {
                loadTokens {
                    val accessToken = secureStorage.getString(
                        AppConstants.ACCESS_TOKEN_KEY) ?: return@loadTokens null
                    val refreshToken = secureStorage.getString(
                        AppConstants.REFRESH_TOKEN_KEY) ?: return@loadTokens null
                    // null 반환 시 요청 실패 처리
                    BearerTokens(accessToken, refreshToken)
                }
                refreshTokens {
                    return@refreshTokens try {
                        val response = client.post("$baseUrl/auth/refresh") {
                            markAsRefreshTokenRequest()
                            contentType(ContentType.Application.Json)
                            setBody(RefreshTokenRequest(oldTokens?.refreshToken ?: ""))
                        }.body<AuthResponse>()

                        secureStorage.putString(
                            AppConstants.ACCESS_TOKEN_KEY, response.accessToken)
                        secureStorage.putString(
                            AppConstants.REFRESH_TOKEN_KEY, response.refreshToken)

                        BearerTokens(response.accessToken, response.refreshToken)
                    } catch (_: Exception) {
                        // RefreshToken 만료 → 토큰 삭제 → 로그인 화면으로
                        secureStorage.remove(AppConstants.ACCESS_TOKEN_KEY)
                        secureStorage.remove(AppConstants.REFRESH_TOKEN_KEY)
                        null  // null 반환 시 요청 실패 처리
                    }
                }
                sendWithoutRequest { requestBuilder ->
                    val paths = requestBuilder.url.pathSegments
                    val isAuthRequest = paths.contains("auth")
                            && (paths.contains("google")
                            || paths.contains("apple"))
                    // Attach authorization header if it's not authentication request
                    !isAuthRequest
                }
            }
        }
        expectSuccess = true
    }

    private val testClient = HttpClient(mockEngine) {
        install(ContentNegotiation) {
            json()
        }
    }

    private var isTest = false

    private val _client: HttpClient
        get() { return if (isTest) testClient else client }

    private val baseUrl = "http://192.168.1.114:3000/api/v1"

    open fun setTestClientStatus(isTest: Boolean? = null) = run {
        if (isTest == null)
            this.isTest = this.isTest.not()
        else
            this.isTest = isTest
    }

    // JSON 요청 — Codable 방식과 동일한 개념
    @Throws(Exception::class)
    suspend fun googleLogin(idToken: String): AuthResponse =
        _client.post("$baseUrl/auth/google") {
            contentType(ContentType.Application.Json)
            setBody(GoogleLoginRequest(idToken))
        }.body()

    @Throws(Exception::class)
    suspend fun appleLogin(identityToken: String, authorizationCode: String?, firstName: String?, lastName: String?): AuthResponse =
        _client.post("$baseUrl/auth/apple") {
            contentType(ContentType.Application.Json)
            setBody(AppleLoginRequest(identityToken, authorizationCode, AppleNameComponent(firstName, lastName)))
        }.body()

    // multipart 요청 — 이미지 파일이 포함될 때
    open suspend fun createFeed(
        content: String?,
        tags: List<String>,
        imageBytes: ByteArray
    ): FeedResponse.Data = _client.post("$baseUrl/feed") {
        contentType(ContentType.Application.Json)
        setBody(MultiPartFormDataContent(
            formData {
                content?.let { append("content", it) }
                tags.forEach { tag -> append("tags", tag) }
                append("images", imageBytes, Headers.build {
                    append(HttpHeaders.ContentType, "image/jpeg")
                    append(HttpHeaders.ContentDisposition, "filename=\"merged.jpg\"")
                })
            }
        ))
    }.body()

    suspend fun getFeed(page: Int, count: Int? = null): FeedResponse {
        var url = "$baseUrl/feed?page=$page"
        if (count != null)
            url += "&limit=$count"
        return _client.get(url).body()
    }

    suspend fun searchFeeds(query: String, page: Int, count: Int? = null): FeedResponse {
        var url = "$baseUrl/feed?page=$page&query=$query"
        if (count != null)
            url += "&limit=$count"
        return _client.get(url).body()
    }

    suspend fun featuredFeeds(): FeedResponse {
        val url = "$baseUrl/feed/featured"
        return _client.get(url).body()
    }

    suspend fun postLike(tobe: Boolean, feedId: String): LikeResponse =
        if (tobe)
            _client.post("feed/$feedId/like").body()
        else
            _client.delete("feed/$feedId/like").body()
}

val mockEngine: MockEngine
    get() = MockEngine { request ->
        when {
            request.url.encodedPath == "/api/v1/feed" && request.method.value == "GET" -> {
                respond(
                    content = ByteReadChannel(FeedMockData.FeedList),
                    status = HttpStatusCode.OK,
                    headers = headersOf(HttpHeaders.ContentType, "application/json")
                )
            }
            request.url.encodedPath == "/api/v1/feed" && request.method.value == "POST" -> {
                respond(
                    content = ByteReadChannel(FeedMockData.CreatedFeed),
                    status = HttpStatusCode.Created,
                    headers = headersOf(HttpHeaders.ContentType, "application/json")
                )
            }
            request.url.encodedPath == "/feed/feed-001/like" -> {
                respond(
                    content = ByteReadChannel("""{"feedId": "feed-001", "likeCount": 1, "isLiked": true}"""),
                    status = HttpStatusCode.OK,
                    headers = headersOf(HttpHeaders.ContentType, "application/json")
                )
            }
            else -> {
                respond(
                    content = ByteReadChannel("""{"error": "Not Found"}"""),
                    status = HttpStatusCode.NotFound,
                    headers = headersOf(HttpHeaders.ContentType, "application/json")
                )
            }
        }
    }