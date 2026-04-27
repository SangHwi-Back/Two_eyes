# Login 화면 정리 작업 목록

> 작성일: 2026-04-22  
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

#### 1. Google Client ID 소스 코드에 하드코딩

```kotlin
// LoginScreen.kt:34~35 — ❌ 현재
BottomSheet("527516655053-906f0v9q6j3ve03omisf9ohitcjq0g3i.apps.googleusercontent.com")
ButtonUI("527516655053-906f0v9q6j3ve03omisf9ohitcjq0g3i.apps.googleusercontent.com")
```

`strings.xml` 또는 `local.properties` → `BuildConfig`로 분리해야 한다.

```xml
<!-- res/values/strings.xml -->
<string name="google_web_client_id">527516655053-....apps.googleusercontent.com</string>
```

```kotlin
// 사용처
val clientId = context.getString(R.string.google_web_client_id)
```

---

#### 2. 로그인 성공 후 idToken 추출 및 서버 전송 로직 없음

`signIn()` 성공 시 `Toast`와 `Log`만 출력하고,  
`GoogleIdTokenCredential`에서 `idToken`을 추출해 서버에 전달하는 로직이 없다.  
현재 로그인이 **실제로 동작하지 않는 상태.**

```kotlin
// signIn() 성공 블록에 추가해야 할 내용
val credential = result.credential
if (credential is GoogleIdTokenCredential) {
    val idToken = credential.idToken
    // TODO: POST /auth/google { idToken } 호출 → accessToken, refreshToken 저장
}
```

---

#### 3. `signIn()`의 반환값이 항상 `null` (버그)

```kotlin
// MainActivity.kt:102
val e: Exception? = null   // 항상 null로 초기화
// ... try/catch (각 catch 블록의 e는 파라미터 — 외부 e를 변경하지 않음)
return e   // 항상 null 반환
```

catch 블록의 `e`는 지역 파라미터이므로 외부 `val e`를 덮어쓰지 않는다.  
`NoCredentialException` catch에서만 `return e`로 명시적 반환이 있어 일관성이 없다.  
반환 타입을 `Boolean` 또는 sealed class로 교체하거나 콜백 방식으로 변경해야 한다.

---

#### 4. `BottomSheet` + `ButtonUI` 중복 호출

`LoginScreen`에서 자동 로그인(`BottomSheet`, LaunchedEffect)과  
수동 버튼 로그인(`ButtonUI`)을 동시에 호출한다.  
`BottomSheet`는 화면 진입 즉시 자동으로 로그인 UI를 트리거하므로  
버튼 클릭 전에 이미 bottom sheet가 뜬다.

의도에 맞게 역할을 하나로 정리해야 한다.

---

#### 5. `@RequiresApi(UPSIDE_DOWN_CAKE)` — Android 14 미만 동작 불가

`BottomSheet`, `ButtonUI`, `signIn()`이 모두 API 34 이상 전용이다.  
`LoginScreen`에서 `@SuppressLint("NewApi")`로 억제하고 있지만  
minSdk가 34 미만이면 런타임 크래시가 발생할 수 있다.  
minSdk 확인 후 하위 버전 대응 분기 또는 minSdk 34 상향을 결정해야 한다.

---

### 🟡 구조 개선

#### 6. 로그인 로직이 `MainActivity.kt`에 혼재

`BottomSheet()`, `ButtonUI()`, `signIn()`, `generateSecureRandomNonce()`가  
`MainActivity.kt`에 정의되어 있다.  
`LoginScreen.kt` 또는 별도 `LoginViewModel`로 이동시켜야 한다.

---

#### 7. 비어있는 버튼

```kotlin
// LoginScreen.kt:30
Button({}) {  // ← onClick 비어있음
    Text("Google Sign in")
}
```

`ButtonUI`와 역할이 중복되며 실제 동작이 없다. 제거하거나 통합한다.

---

#### 8. 에러 처리를 `Toast`로만 처리

`signIn()` 실패 시 `Toast`와 `Log`만 사용한다.  
`LoginScreen`의 UI 상태(`StateFlow` 또는 `State<String?>`)로 에러를 노출해  
화면에 표시하는 방식으로 개선한다.

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
| 1 | iOS | `identityToken!` 강제 언래핑 제거 |
| 1 | iOS | `onCompletion`에 Keychain 저장 추가 |
| 1 | Android | `signIn()` 반환값 버그 수정 |
| 1 | Android | 로그인 성공 후 idToken 추출 로직 추가 |
| 2 | iOS | `checkStatus()` 로직 수정 (provider별 분기) |
| 2 | iOS | `googleCheckState()` 중복 `dismiss()` 제거 |
| 2 | Android | Client ID `strings.xml` 분리 |
| 2 | Android | `BottomSheet` + `ButtonUI` 중복 정리 |
| 2 | 공통 | 서버 API 호출 + 토큰 저장 구현 |
| 3 | iOS | 데드 코드 9개 제거 |
| 3 | Android | 로그인 로직 `MainActivity.kt`에서 분리 |
| 3 | Android | 에러 처리 UI 상태로 교체 |
