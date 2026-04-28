# Login 화면 정리 작업 목록

> 최초 작성: 2026-04-22 / 최종 갱신: 2026-04-28  
> 대상: iOS `LoginView.swift` / Android `LoginScreen.kt`  
> 범위: 서버 코드 제외, 클라이언트 로그인 화면만

---

## iOS

### 🔴 버그 — 반드시 수정

#### 1. Apple 로그인 후 Keychain에 저장되지 않음

`SignInWithAppleButton`의 `onCompletion`에서 `userData`는 업데이트하지만  
Keychain 저장이 누락되어 **앱 재시작 시 로그인 상태가 사라진다.**

```swift
// LoginView.swift — onCompletion 수정
case .success(let authorization):
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        let data = AppleUserData(credential: appleIDCredential)
        try? KeychainModel<AppleUserData>().saveItem(data)   // ← 추가
        self.userData.wrappedValue = .apple(data)
    }
```

---

#### 2. `identityToken`, `authorizationCode` 강제 언래핑 크래시 위험

`LoginView+Keychain.swift`의 `AppleUserData.init(credential:)` 내부.  
`credential.identityToken`과 `credential.authorizationCode`는 `Data?`이므로  
nil일 경우 앱이 크래시된다.

```swift
// ❌ 현재
self.identityToken    = String(data: credential.identityToken!, encoding: .utf8)
self.authorizationCode = String(data: credential.authorizationCode!, encoding: .utf8)

// ✅ 수정
self.identityToken    = credential.identityToken.flatMap    { String(data: $0, encoding: .utf8) }
self.authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }
```

---

#### 3. `checkStatus()` 로직이 userData 케이스와 맞지 않음

현재: Apple 상태 확인 실패 시 무조건 Google 상태를 체크하는 폴백 구조.  
Apple로 로그인한 유저도 Google restore를 시도한다.

```swift
// ✅ 수정 — userData 케이스에 따라 해당 provider만 확인
func checkStatus() async {
    switch userData.wrappedValue {
    case .apple:
        guard (try? await appleCheckState()) == .authorized else { return }
        dismiss()
    case .google:
        guard (try? await googleCheckState()) == .authorized else { return }
        dismiss()
    case nil:
        return   // 로그인 필요, 화면 유지
    }
}
```

---

#### 4. `googleCheckState()` 내부에서 `dismiss()` 중복 호출

`googleCheckState()`가 내부에서 `dismiss()`를 호출하고,  
`checkStatus()`에서도 `dismiss()`를 추가로 호출한다.  
`googleCheckState()`의 `dismiss()` 제거하고 반환값만 사용한다.

---

### 🟡 데드 코드 제거

| 항목 | 위치 | 이유 |
|------|------|------|
| `appleLogin()` 함수 | `LoginView.swift:151` | `SignInWithAppleButton` 사용으로 호출처 없음 |
| `@State appleLoginContext` | `LoginView.swift:35` | `appleLogin()` 제거 시 불필요 |
| `@State appleLoginDelegate` | `LoginView.swift:36` | 동일 |
| `isAppleLoggedIn` | `LoginView.swift:30` | 어디서도 읽히지 않음 |
| `isGoogleLoggedIn` | `LoginView.swift:31` | 설정 직후 `dismiss()` — 의미 없음 |
| `googleLogout()` | `LoginView.swift:191` | 로그인 화면에 있을 이유 없고 호출처 없음 |
| `SignInWithGoogleButton` (UIViewRepresentable) | `LoginView.swift:204` | `GoogleSignInButton`(SwiftUI) 사용 중 — 불필요 |
| `AppleAuthorizationControllerDelegate` | `LoginView+AuthenticationServices.swift` | `appleLogin()` 제거 시 함께 제거 |
| `AppleAuthorizationControllerUIContext` | `LoginView+AuthenticationServices.swift` | 동일 |

---

## Android

### 🔴 버그 — 반드시 수정

#### 1. `getIDToken() == null` 조건이 절대 `true`가 되지 않음

```kotlin
// LoginViewModel.kt
fun getIDToken() = pref.getString(ID_TOKEN_KEY, "")  // 토큰 없으면 "" 반환

// LoginScreen.kt
if (viewmodel.getIDToken() == null)   // "" != null → 항상 false
```

`EncryptedSharedPreferences.getString()`의 기본값이 `""`이므로  
토큰이 없어도 `null`이 아닌 빈 문자열이 반환된다.  
결과적으로 `BottomSheet`가 이미 로그인된 상태에서도 항상 표시된다.

```kotlin
// ✅ 수정 — 둘 중 하나 선택
// 방법 A: 기본값을 null로
fun getIDToken() = pref.getString(ID_TOKEN_KEY, null)

// 방법 B: LoginScreen에서 비어있는지까지 확인
if (viewmodel.getIDToken().isNullOrEmpty())
```

---

#### 2. `signIn()` 성공 시 idToken이 잘못 추출됨

```kotlin
// LoginScreen.kt:148 — ❌ 현재
completionHandler(null, result.toString())   // GetCredentialResponse 객체의 toString()
```

`result.toString()`은 객체 문자열 표현이지 실제 Google ID 토큰이 아니다.  
`GoogleIdTokenCredential`에서 `.idToken`을 꺼내야 한다.

```kotlin
// ✅ 수정
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential

val credential = result.credential
if (credential is GoogleIdTokenCredential) {
    completionHandler(null, credential.idToken)
} else {
    completionHandler(IllegalStateException("Unexpected credential type: ${credential::class}"), null)
}
```

---

### 🟡 구조 개선

#### 3. NoCredentialException 폴백 로직이 UI에 혼재

```kotlin
// LoginScreen.kt — BottomSheet completionHandler 내부
} else if (exception is NoCredentialException) {
    val googleIdOptionFalse = GetGoogleIdOption.Builder()
        .setFilterByAuthorizedAccounts(false)
        ...
    scope.launch { signIn(requestFalse, context) { ... } }
}
```

새 request를 직접 생성하고 `signIn()`을 재호출하는 로직은 UI 책임이 아니다.  
`BottomSheet` 또는 `LoginViewModel`로 이동시켜야 한다.

---

#### 6. `@RequiresApi(UPSIDE_DOWN_CAKE)` / `@SuppressLint("NewApi")` 미해결

`ButtonUI`, `BottomSheet`, `signIn()` 모두 API 34 이상 전용이다.  
`LoginScreen`에서 `@SuppressLint("NewApi")`로 억제 중이나  
minSdk 34 미만 기기에서는 런타임 크래시가 발생할 수 있다.  
`build.gradle`의 `minSdk` 값을 확인하고, 34 미만이면 분기 처리 또는 상향을 결정해야 한다.

---

#### 7. 에러 처리를 `Toast`로만 처리

`signIn()` 실패 시 `Toast`와 `Log`만 사용한다.  
`LoginScreen`의 UI 상태(`StateFlow` 또는 `mutableStateOf<String?>`)로 에러를 노출해  
화면에 텍스트로 표시하는 방식으로 개선한다.

---

## 공통 — 로그인 완료 후 처리 (iOS + Android 모두 미구현)

로그인 성공 시 서버 API 호출 및 토큰 저장이 양 플랫폼 모두 빠져 있다.

| 단계 | 내용 |
|------|------|
| 1 | 소셜 로그인 성공 → `idToken` 추출 |
| 2 | `POST /auth/google` 또는 `POST /auth/apple` 호출 |
| 3 | 응답의 `accessToken`, `refreshToken` 저장 (iOS: Keychain, Android: EncryptedSharedPreferences 등) |
| 4 | 이후 모든 API 호출에 `Authorization: Bearer {accessToken}` 헤더 포함 |
| 5 | `accessToken` 만료 시 `POST /auth/refresh` 호출하여 갱신 |

---

## 작업 우선순위 요약

| 우선순위 | 플랫폼 | 항목 |
|:--------:|--------|------|
| 1 | Android | `getIDToken()` 기본값 `""` → `null` 로 수정 (BottomSheet 조건 버그) |
| 1 | Android | `signIn()` 성공 시 `GoogleIdTokenCredential.idToken` 올바르게 추출 |
| 1 | iOS | `identityToken!` 강제 언래핑 제거 |
| 1 | iOS | `onCompletion`에 Keychain 저장 추가 |
| 2 | iOS | `checkStatus()` 로직 수정 (provider별 분기) |
| 2 | iOS | `googleCheckState()` 중복 `dismiss()` 제거 |
| 2 | 공통 | 서버 API 호출 + 토큰 저장 구현 |
| 3 | iOS | 데드 코드 9개 제거 |
| 3 | Android | NoCredentialException 폴백 로직 LoginViewModel로 이동 |
| 3 | Android | `minSdk` 확인 후 `@RequiresApi` 대응 방법 결정 |
| 3 | Android | 에러 처리 UI 상태로 교체 |
