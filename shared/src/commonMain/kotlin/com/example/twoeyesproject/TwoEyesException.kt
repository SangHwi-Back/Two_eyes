package com.example.twoeyesproject

/**
 * 모든 플랫폼에서 공통으로 사용하는 예외 계층.
 *
 * - [message]     : 기술적 식별자 (짧고 기계 친화적)
 * - [description] : 사람이 읽기 좋은 긴 설명 (iOS LocalizedError.errorDescription 역할)
 * - [cause]       : 원본 예외 보존 — 유닛 테스트에서 assertIs<IOException>(ex.cause) 식으로 검증 가능
 *
 * KMP sealed class → ObjC abstract class 계층으로 노출되므로
 * Swift 에서 `catch let e as TwoEyesException.Http` 패턴이 그대로 동작한다.
 */
sealed class TwoEyesException(
    message: String,
    val description: String,
    cause: Throwable? = null,
) : Exception(message, cause) {

    /** 연결 오류, 타임아웃 등 네트워크 레이어 실패 */
    class Network(
        message: String,
        description: String = "네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.",
        cause: Throwable? = null,
    ) : TwoEyesException(message, description, cause)

    /** HTTP 4xx / 5xx 응답 */
    class Http(
        val statusCode: Int,
        message: String,
        description: String = "서버 요청 처리 중 오류가 발생했습니다. (HTTP $statusCode)",
        cause: Throwable? = null,
    ) : TwoEyesException(message, description, cause)

    /** Room / SQLite 등 로컬 DB 오류 */
    class Database(
        message: String,
        description: String = "데이터 저장 또는 조회 중 문제가 발생했습니다.",
        cause: Throwable? = null,
    ) : TwoEyesException(message, description, cause)

    /** 인증 / 토큰 관련 오류 */
    class Authentication(
        message: String,
        description: String = "인증에 실패했습니다. 다시 로그인해주세요.",
        cause: Throwable? = null,
    ) : TwoEyesException(message, description, cause)

    /** 분류되지 않은 예외 */
    class Unknown(
        message: String,
        description: String = "알 수 없는 오류가 발생했습니다.",
        cause: Throwable? = null,
    ) : TwoEyesException(message, description, cause)
}
