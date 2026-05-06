package com.example.twoeyesproject.dependency

// ApiClient.kt
import com.example.twoeyesproject.platformspecific.platformHttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.delete
import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.HttpResponse
import io.ktor.http.ContentType
import io.ktor.http.Headers
import io.ktor.http.HttpHeaders
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
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

class ApiClient {
    private val client = platformHttpClient().config {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true })
        }
        expectSuccess = true
    }

    private val baseUrl = "http://192.168.1.114:3000/api/v1"

    // JSON 요청 — Codable 방식과 동일한 개념
    @Throws(Exception::class)
    suspend fun googleLogin(idToken: String): AuthResponse =
        client.post("$baseUrl/auth/google") {
            contentType(ContentType.Application.Json)
            setBody(GoogleLoginRequest(idToken))
        }.body()

    @Throws(Exception::class)
    suspend fun appleLogin(identityToken: String, authorizationCode: String?, firstName: String?, lastName: String?): AuthResponse =
        client.post("$baseUrl/auth/apple") {
            contentType(ContentType.Application.Json)
            setBody(AppleLoginRequest(identityToken, authorizationCode, AppleNameComponent(firstName, lastName)))
        }.body()

    @Throws(Exception::class)
    suspend fun refreshToken(refreshToken: String): AuthResponse =
        client.post("$baseUrl/auth/refresh") {
            contentType(ContentType.Application.Json)
            setBody(RefreshTokenRequest(refreshToken))
        }.body()

    // multipart 요청 — 이미지 파일이 포함될 때
    suspend fun createFeed(
        accessToken: String,
        content: String?,
        tags: List<String>,
        imageBytes: ByteArray
    ) = client.post("$baseUrl/feed") {
        header(HttpHeaders.Authorization, "Bearer $accessToken")
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
    }

    suspend fun getFeed(
        accessToken: String,
        page: Int,
        count: Int? = null,
    ): FeedResponse = client.get("$baseUrl/feed") {
        header(HttpHeaders.Authorization, "Bearer $accessToken")
    }.body()
    
    suspend fun postLike(
        accessToken: String,
        tobe: Boolean,
        feedId: String,
    ): HttpResponse = if (tobe == true) {
        client.post("feed/$feedId/like") {
            header(HttpHeaders.Authorization, "Bearer $accessToken")
        }
    } else {
        client.delete("feed/$feedId/like") {
            header(HttpHeaders.Authorization, "Bearer $accessToken")
        }
    }
}