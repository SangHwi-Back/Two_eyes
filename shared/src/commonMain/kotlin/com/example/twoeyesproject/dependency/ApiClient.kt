package com.example.twoeyesproject.dependency

// ApiClient.kt
import com.example.twoeyesproject.platformspecific.platformHttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.Headers
import io.ktor.http.HttpHeaders
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.Serializable

// ── JSON 요청에 쓸 data class (Codable 과 같은 역할) ──────────────

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

// ── 클라이언트 ─────────────────────────────────────────────────────

class ApiClient {
    private val client = platformHttpClient().config {
        install(ContentNegotiation) { json() }
    }

    private val baseUrl = "http://localhost:3000/api/v1"

    // JSON 요청 — Codable 방식과 동일한 개념
    suspend fun googleLogin(idToken: String): AuthResponse =
        client.post("$baseUrl/auth/google") {
            contentType(ContentType.Application.Json)
            setBody(GoogleLoginRequest(idToken))
        }.body()

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
}