# Two Eyes

사진 필터 앱입니다. 원본 사진과 필터가 적용된 사진을 나란히 겹쳐보고, 피드에 공유할 수 있습니다.

> iPadOS는 지원하지 않을 예정입니다.

---

## 플랫폼

| 플랫폼 | UI 프레임워크 | 최소 버전 |
|--------|-------------|---------|
| Android | Jetpack Compose | API 24 (Android 7.0) |
| iOS | SwiftUI | iOS 16+ |

---

## 기술 스택

### 공통 (Kotlin Multiplatform)
- **Kotlin** 2.4.0 · **Kotlin Multiplatform (KMP)**
- **Ktor** 3.4.1 — HTTP 클라이언트 (REST API, Bearer 토큰 인증)
- **Room** 2.8.4 — 로컬 DB (합성 이미지 저장)
- **Koin** 4.x — 의존성 주입 (commonMain: `factory`, androidMain: `viewModel`)
- **Kotlinx Coroutines** 1.10.2
- **Kotlinx Serialization** 1.9.0

### Android
- **Jetpack Compose** (Compose Multiplatform 1.10.0)
- **Material 3** — `darkColorScheme` 기반 커스텀 테마
- **Jetpack Navigation** (Compose)
- **EncryptedSharedPreferences** — 토큰 보안 저장

### iOS
- **SwiftUI**
- **PhotoKit (PHImageManager)** — 사진 라이브러리 접근
- **AVFoundation** — 카메라
- **KeychainServices** — 토큰 보안 저장
- **Sign in with Apple / Google Sign-In**

---

## 주요 기능

### 피드 (Feed)
- 서버에서 피드 목록을 불러와 카드 형태로 표시
- 좋아요
- 검색 (키워드 기반, Featured 탭 포함)

### 이미지 선택 & 합성 (PickImage)
- 기기 카메라로 촬영 또는 사진 라이브러리에서 선택
- 두 이미지를 나란히 합성 (오프셋/위치 조정 지원)
- 합성 결과를 기기에 저장 또는 피드에 업로드

### 업로드 (Upload)
- 합성 이미지에 내용·태그를 추가해 서버에 업로드
- 업로드 이력을 로컬 DB(Room)에 저장

### 로그인
- Apple 로그인 / Google 로그인
- JWT Access/Refresh 토큰 관리 (자동 갱신)

---

## 아키텍처

```
Two_eyes
├── shared/                         # KMP 공통 모듈
│   └── src/
│       ├── commonMain/             # 비즈니스 로직, ViewModel, API, DB
│       │   └── .../
│       │       ├── feed/           # FeedListViewModel, FeedSearchViewModel
│       │       ├── image/          # PickImageViewModel, PickImageMergeViewModel, ImageMerger
│       │       ├── upload/         # UploadViewModel
│       │       ├── dependency/     # ApiClient, AppDatabase, FeedMockData
│       │       ├── di/             # SharedModule (Koin)
│       │       ├── platformspecific/ # expect/actual 선언
│       │       ├── AppErrorBus.kt  # 중앙 에러 버스 (StateFlow + iOS 콜백)
│       │       └── TwoEyesViewModel.kt # 공통 ViewModel 기반 클래스
│       ├── androidMain/            # Android actual 구현체
│       └── iosMain/                # iOS actual 구현체 (KN)
│
├── composeApp/                     # Android 앱
│   └── src/androidMain/
│       └── .../
│           ├── ui/feed/            # FeedScreen
│           ├── ui/upload/          # UploadScreen, UploadCreateFeedScreen
│           ├── ui/camera/          # PickImageScreen, PickImageMergeScreen
│           ├── App.kt              # MaterialTheme + AppScaffold + 에러 Alert
│           └── DynamicTopAppBar.kt # 화면별 TopAppBar 통합 관리
│
└── iosApp/                         # iOS 앱 (SwiftUI)
    └── iosApp/
        ├── Feed/                   # FeedListView, FeedItemView
        ├── PickImage/              # PickImageView, PickImageMergeView
        ├── Upload/                 # UploadView, UploadCreateFeedView
        ├── Login/                  # LoginView + Apple/Google 인증
        └── iOSApp.swift            # 앱 진입점, 에러 Alert
```

### ViewModel 공유 방식

| 구분 | Android | iOS |
|------|---------|-----|
| ViewModel 인스턴스 | `koinViewModel<T>()` | `*ViewModelWrapper: ObservableObject` |
| 에러 전파 | `AppErrorBus.error` (StateFlow → `collectAsStateWithLifecycle`) | `AppErrorCallback` (fun interface) |
| 비동기 | Coroutine scope (ViewModel) | `Task {}` (Swift Concurrency) |

---

## 에러 처리

모든 ViewModel은 `TwoEyesViewModel`을 상속하며, 에러 발생 시 `emitError(TwoEyesException)`을 호출합니다.
`AppErrorBus`가 이를 수신해 플랫폼 루트(`App.kt` / `iOSApp.swift`)에서 Alert를 표시합니다.

```
ViewModel.emitError()
    └→ AppErrorBus.post(UserFacingError)
            ├→ [Android] StateFlow → AlertDialog
            └→ [iOS]    AppErrorCallback → .alert()
```

---

## 브랜치 전략

Gitflow Workflow 기반

- `main` — 릴리즈
- `develop` — 통합 개발
- `feature/*` — 기능 개발
