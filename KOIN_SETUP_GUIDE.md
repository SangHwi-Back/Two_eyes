# 🔧 Koin 의존성 주입 가이드

Kotlin Multiplatform 프로젝트에서 Koin을 사용하여 의존성 주입을 구현하는 완전한 가이드입니다.

---

## 📦 1. 프로젝트 구조

```
shared/
├── commonMain/
│   └── di/
│       └── SharedModule.kt          # 공통 DI 모듈
├── androidMain/
│   └── di/
│       └── SharedModule.android.kt  # Android 전용 모듈
└── iosMain/
    └── di/
        ├── SharedModule.ios.kt      # iOS 전용 모듈
        └── KoinInitializer.kt       # iOS Koin 초기화
```

---

## 🔨 2. Koin 모듈 정의

### commonMain - 공통 모듈

```kotlin
// shared/src/commonMain/kotlin/com/example/twoeyesproject/di/SharedModule.kt
val sharedCommonModule = module {
    // Singleton: 앱 전체에서 하나의 인스턴스
    single { ApiClient() }

    // ViewModel: 화면마다 새 인스턴스
    viewModel { LoginViewModel(context = null) }
    viewModel { FeedListViewModel(apiClient = get()) }
    viewModel { PickImageViewModel() }
    viewModel { PickImageMergeViewModel() }
}
```

### androidMain - Android 전용 모듈

```kotlin
// shared/src/androidMain/kotlin/com/example/twoeyesproject/di/SharedModule.android.kt
val sharedAndroidModule = module {
    single { getRoomDatabase(getDatabaseBuilder(androidContext())) }
    viewModel { UploadViewModel(db = get()) }
}
```

### iosMain - iOS 전용 모듈

```kotlin
// shared/src/iosMain/kotlin/com/example/twoeyesproject/di/SharedModule.ios.kt
val sharedIosModule = module {
    single { getRoomDatabase(getDatabaseBuilder()) }
    viewModel { UploadViewModel(db = get()) }
}
```

---

## 🚀 3. Koin 초기화

### Android

```kotlin
// TwoEyesApplication.kt
class TwoEyesApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@TwoEyesApplication)
            modules(
                sharedCommonModule,   // 공통 모듈
                sharedAndroidModule   // Android 전용
            )
        }
    }
}
```

### iOS

```kotlin
// KoinInitializer.kt
fun initKoin() {
    startKoin {
        modules(
            sharedCommonModule,  // 공통 모듈
            sharedIosModule      // iOS 전용
        )
    }
}
```

Swift에서 호출:
```swift
// iosApp/iOSApp.swift
import Shared

@main
struct iOSApp: App {
    init() {
        KoinInitializerKt.initKoin()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## 💉 4. Koin 사용법

### Compose에서 ViewModel 주입

```kotlin
@Composable
fun FeedScreen() {
    // 방법 1: 타입 명시
    val viewModel: FeedListViewModel = koinViewModel()

    // 방법 2: 타입 추론
    val viewModel = koinViewModel<FeedListViewModel>()
}
```

### 일반 클래스에서 주입

```kotlin
class MyRepository {
    // 지연 주입 (lazy injection)
    private val apiClient: ApiClient by inject()

    // 또는 직접 가져오기
    private val apiClient = KoinPlatform.getKoin().get<ApiClient>()
}
```

---

## 🧪 5. 테스트에서 Koin 사용

### 테스트 모듈 작성

```kotlin
class UploadViewModelTest : KoinTest {

    @BeforeTest
    fun setup() {
        startKoin {
            modules(module {
                single<AppDatabase> { mockDatabase }
                single { ApiClient() }
            })
        }
    }

    @AfterTest
    fun tearDown() {
        stopKoin()
    }

    @Test
    fun `test with Koin injection`() = runTest {
        val viewModel = UploadViewModel(get())
        // 테스트 로직...
    }
}
```

---

## 🎯 6. Koin DSL 정리

| DSL | 설명 | 사용 예시 |
|-----|------|----------|
| `single { }` | Singleton (앱 전체 1개) | `single { ApiClient() }` |
| `factory { }` | 요청마다 새 인스턴스 | `factory { UserRepository() }` |
| `viewModel { }` | ViewModel (화면마다 새 인스턴스) | `viewModel { MyViewModel() }` |
| `get()` | 의존성 주입 | `viewModel { MyViewModel(get()) }` |
| `inject()` | 지연 주입 | `val api: ApiClient by inject()` |

---

## ⚠️ 7. 주의사항

### ViewModel 생성자 주입

```kotlin
// ✅ 좋은 예: 의존성을 생성자로 주입
class FeedListViewModel(
    private val apiClient: ApiClient
) : ViewModel()

// ❌ 나쁜 예: 내부에서 직접 생성
class FeedListViewModel : ViewModel() {
    private val apiClient = ApiClient()  // 테스트 불가!
}
```

### 플랫폼별 의존성

- **공통 모듈**: 모든 플랫폼에서 사용 가능한 것만
- **플랫폼 모듈**: Room, Context 등 플랫폼별 의존성

```kotlin
// ✅ 공통 모듈
single { ApiClient() }  // Ktor는 멀티플랫폼

// ❌ 공통 모듈에 넣으면 안됨
single { getRoomDatabase() }  // Room은 플랫폼별로 초기화 필요
```

---

## 🔍 8. 트러블슈팅

### "No definition found for..."

```kotlin
// 문제: 모듈에 정의되지 않음
val viewModel: MyViewModel = koinViewModel()  // ❌

// 해결: 모듈에 추가
val sharedCommonModule = module {
    viewModel { MyViewModel() }  // ✅
}
```

### "Koin is not started"

```kotlin
// Android: TwoEyesApplication에서 startKoin() 호출 확인
// iOS: init()에서 initKoin() 호출 확인
```

---

## 📚 참고 자료

- [Koin 공식 문서](https://insert-koin.io/)
- [Koin Multiplatform](https://insert-koin.io/docs/reference/koin-mp/kmp)
- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html)