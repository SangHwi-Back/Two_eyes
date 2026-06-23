# 📊 ViewModel 유닛테스트 현황 분석

## ✅ 테스트가 있는 ViewModel (4개)

1. LoginViewModel → LoginViewModelTest.kt ✓
2. FeedListViewModel → FeedListViewModelTest.kt ✓
3. PickImageViewModel → PickImageViewModelTest.kt ✓
4. PickImageMergeViewModel → PickImageMergeViewModelTest.kt ✓

## ❌ 테스트가 없는 ViewModel (1개)

UploadViewModel (shared/src/commonMain/kotlin/com/example/twoeyesproject/upload/UploadViewModel.kt:15)

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

### LoginViewModel - ✅ 테스트 가능 (테스트 존재)

현재 테스트 커버리지:
- ✅ Apple/Google 로그인 상태 확인
- ✅ 사용자 데이터 저장/조회/삭제
- ✅ 에러 상태 관리
- ✅ delegate 콜백 경로 검증

특징:
- 플랫폼별 분기 처리 (getPlatform())
- 모든 의존성이 생성자/프로퍼티로 주입됨
- Flow 기반 상태 관리

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
| LoginViewModel          | ✅      | 🟢 높음   | 플랫폼 분기만 주의               |
| FeedListViewModel       | ✅      | 🟡 중간   | API Mock 필요, 에러 처리 개선 필요 |
| PickImageViewModel      | ✅      | 🟢 높음   | 플랫폼 이미지 로딩만 제외           |
| PickImageMergeViewModel | ✅      | 🟢 높음   | 플랫폼 이미지 처리만 제외           |
| UploadViewModel         | ❌      | 🔴 낮음   | 의존성 하드코딩, 플랫폼 의존성        |

UploadViewModel만 유닛테스트가 작성되지 않았으며, 현재 구조상 테스트가 어렵습니다. 테스트 가능하게 만들려면 의존성 주입 리팩토링이 필요합니다.

UploadViewModel의 유닛테스트를 작성해드릴까요?

