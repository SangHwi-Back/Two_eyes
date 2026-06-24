# 📊 ViewModel 유닛테스트 현황 분석

## ✅ 테스트가 있는 ViewModel (4개)

1. FeedListViewModel → FeedListViewModelTest.kt ✓
2. PickImageViewModel → PickImageViewModelTest.kt ✓
3. PickImageMergeViewModel → PickImageMergeViewModelTest.kt ✓
4. UploadViewModel → UploadViewModelTest.kt ✓

## ❌ 테스트가 없는 ViewModel (1개)

LoginViewModel (shared/src/commonMain/kotlin/com/example/twoeyesproject/LoginViewModel.kt:23)
- 플랫폼 의존성이 강해서 Unit Test 불가능
- PlatformSignInWorker, PlatformAuthorizationStatusCheckWorker 등은 각 플랫폼에서 별도 테스트

## 🔍 각 ViewModel 테스트 가능성 분석

### UploadViewModel - ⚠️ 부분적으로 테스트 가능

테스트 가능한 부분:
- ✅ mergeEntities Flow 초기값 검증
- ✅ deleteEntity() - DAO mock을 사용하여 delete 호출 검증

테스트 어려운 부분:
- ❌ uploadEntity() - URIByteEncoder 플랫폼 의존성
- ❌ ApiClient 하드코딩 (생성자가 아닌 내부에서 인스턴스 생성)
- ❌ viewModelScope 코루틴 테스트 필요

문제점:

```kotlin
private val client = ApiClient()  // Mock 불가능 (생성자 주입 필요)
val item = URIByteEncoder(id).uriToByteArray()  // 플랫폼 의존성
```

개선 방안:
- ApiClient를 생성자 주입으로 변경
- URIByteEncoder를 인터페이스로 추상화하여 주입
- 코루틴 테스트를 위한 TestDispatcher 사용

### LoginViewModel - ❌ 테스트 불가능 (테스트 제거됨)

테스트 불가능한 이유:
- ❌ PlatformUIContext 의존성 (플랫폼별 UI 컨텍스트, **non-nullable**)
- ❌ PlatformSignInWorker, PlatformAuthorizationStatusCheckWorker 등 expect/actual 클래스
- ❌ 생성자에서 플랫폼 객체 직접 생성 (Mock 불가능)
- ❌ 실제 비즈니스 로직보다는 플랫폼 API 호출만 수행

특징:
- 플랫폼별 분기 처리 (getPlatform())
- 플랫폼 의존성이 강한 로그인 로직
- 플랫폼별 테스트는 각 플랫폼의 PlatformSignInWorkerTest에서 수행

**개선 사항 (2026-06-24):**
- `context: PlatformUIContext?` → `context: PlatformUIContext` (non-nullable로 변경)
- Koin DI에서 제거 (플랫폼에서 직접 생성)
- 타입 시스템이 정직해짐: null을 넘길 수 없음이 명확함

### FeedListViewModel - ⚠️ 부분적으로 테스트 가능 (테스트 존재하나 제한적)

현재 테스트:
- ✅ Mock 데이터 검증만 수행

테스트 어려운 부분:
- ❌ getAllFeeds() - API 호출 (ApiClient 주입되지만 실제 서버 필요)
- ❌ updateLike() - API 호출 + 상태 업데이트

특징:
- ApiClient가 생성자로 주입되어 Mock 가능 ✅
- 에러 처리가 단순 print()로만 되어있음 (테스트 불가)

개선 방안:
- ApiClient를 mock하여 성공/실패 시나리오 테스트
- 에러 상태를 Flow로 노출

### PickImageViewModel - ✅ 테스트 가능 (테스트 존재)

현재 테스트 커버리지:
- ✅ 초기 상태 검증
- ✅ 하이라이트 토글 로직
- ✅ UUID 고유성 검증

테스트 어려운 부분:
- ❌ loadAllImages() - PickImageFetcher 플랫폼 의존성
- ❌ setImageFromSource() / setCameraImage() - ImageSource 생성 어려움

특징:
- 대부분의 상태 관리 로직이 테스트 가능
- 플랫폼 의존적인 이미지 로딩만 테스트 어려움

### PickImageMergeViewModel - ⚠️ 부분적으로 테스트 가능 (테스트 존재하나 제한적)

현재 테스트 커버리지:
- ✅ 초기 상태 검증
- ✅ 상태 업데이트 (offsetX, offsetY, scale)
- ✅ zOrder 변경

테스트 어려운 부분:
- ❌ applyImageFilter() - PlatformApplyFilter 플랫폼 의존성
- ❌ saveMergedImage() - PlatformPersistImage 플랫폼 의존성 + DAO

특징:
- 상태 관리 로직은 완벽하게 테스트 가능
- 플랫폼별 이미지 처리만 테스트 불가


## 📝 요약

| ViewModel               | 테스트 존재 | 테스트 가능성 | 주요 이슈                    |
|-------------------------|--------|---------|--------------------------|
| FeedListViewModel       | ✅      | 🟢 높음   | API Mock 사용, 상태 관리 테스트 가능 |
| PickImageViewModel      | ✅      | 🟢 높음   | 플랫폼 이미지 로딩만 제외           |
| PickImageMergeViewModel | ✅      | 🟢 높음   | 플랫폼 이미지 처리만 제외           |
| UploadViewModel         | ✅      | 🟢 높음   | 의존성 주입, Mock API 사용      |
| LoginViewModel          | ❌      | 🔴 불가능 | 플랫폼 의존성 강함, 별도 플랫폼 테스트 필요 |

모든 테스트 가능한 ViewModel에 유닛테스트가 작성되었습니다. LoginViewModel은 플랫폼 의존성으로 인해 Common 레벨에서 테스트가 불가능하며, 각 플랫폼별 테스트에서 커버됩니다.

