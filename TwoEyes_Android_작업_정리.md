# TwoEyes Android 작업 정리

## 버그 수정

| 파일 | 문제 | 수정 내용 |
|---|---|---|
| `FeedFragment.kt` | `binding` inflate 후 `binding.root` 미반환 | `return binding.root` 수정 |
| `FeedItemModel.kt` | `android.media.Image` (하드웨어 raw 타입) 사용 | `android.net.Uri` 로 교체 |
| `fragment_feed.xml` | RecyclerView에 id 없음 | `@+id/feed_recycler_view` 추가 |
| `CameraActivity.kt` | 펀치홀 카메라 영역 겹침 | `displayCutout` insets 추가 |
| `activity_camera.xml (land)` | `layout_constraintEnd_toEnd` (존재하지 않는 속성) | `layout_constraintEnd_toEndOf` 로 수정 |

---

## 1단계 - FileProvider 설정

- `res/xml/file_provider_paths.xml` 생성
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-cache-path name="camera_images" path="." />
</paths>
```
- `AndroidManifest.xml`에 `<provider>` 등록
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_provider_paths" />
</provider>
```

---

## 2단계 - 카메라 실행 방식 변경 (썸네일 → EXTRA_OUTPUT)

- `data` extra (썸네일 Bitmap) → `EXTRA_OUTPUT` 방식으로 변경
- `pendingImageUri` 프로퍼티로 촬영 전 임시 Uri 관리
- `takePictureLauncher`에서 `pendingImageUri` 로 결과 수신

```kotlin
private var pendingImageUri: Uri? = null

private fun launchCamera() {
    val imageFile = File(
        getExternalFilesDir(Environment.DIRECTORY_PICTURES),
        "camera_${System.currentTimeMillis()}.jpg"
    )
    val imageUri = FileProvider.getUriForFile(
        this,
        "${packageName}.fileprovider",
        imageFile
    )
    pendingImageUri = imageUri
    takePictureLauncher.launch(
        Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
            putExtra(MediaStore.EXTRA_OUTPUT, imageUri)
        }
    )
}

private val takePictureLauncher = registerForActivityResult(
    ActivityResultContracts.StartActivityForResult()
) { result ->
    val uri = pendingImageUri
    if (result.resultCode == RESULT_OK && uri != null)
        viewModel.addItem(uri)
    else
        showToast("Failed to get image")
    pendingImageUri = null
}
```

---

## 3단계 - 저장 위치 결정

| 저장소 | 코드 | 특징 |
|---|---|---|
| `externalCacheDir` | 기존 사용 | 시스템이 용량 부족 시 자동 삭제 가능 ⚠️ |
| `getExternalFilesDir(...)` | **채택** | 앱이 직접 관리, 권한 불필요, 앱 삭제 시 삭제 |
| `filesDir` | - | 가장 안전하지만 용량 제한적 |
| `MediaStore` | - | 갤러리 저장, 앱 삭제 후에도 유지 |

- **`getExternalFilesDir(Environment.DIRECTORY_PICTURES)`** 사용
- 업로드 완료 후 `imageFile.delete()` 로 정리 예정

---

## 4단계 - 저장 로직 구현

- `CameraViewModel` 타입 `Any` → `Uri` 로 통일
- `ThumbnailAdapter` 타입 `Any` → `Uri` 로 수정
- 갤러리 이미지 복사 시 `Dispatchers.IO` 사용

```kotlin
fun copyToAppStorage(context: Context, sourceUri: Uri) {
    viewModelScope.launch(Dispatchers.IO) {
        val destFile = File(
            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES),
            "gallery_${System.currentTimeMillis()}.jpg"
        )
        context.contentResolver.openInputStream(sourceUri)?.use { input ->
            destFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
        _items.value = _items.value + Uri.fromFile(destFile)
    }
}
```

- `AndroidManifest.xml`에 `INTERNET` 권한 추가

---

## 5단계 - 저장된 Uri를 UploadFragment로 전달

- 전달 대상: `FeedFragment`가 아닌 **`UploadFragment`**
- `CameraActivity`에서 `finishWithResult()` 로 Uri 목록 전달

```kotlin
private fun finishWithResult() {
    val selectedUris = viewModel.selectedImages.value
        .filterNotNull()
        .map { it.toString() }
    val resultIntent = Intent().apply {
        putStringArrayListExtra(CAMERA_RESULT_KEY, ArrayList(selectedUris))
    }
    setResult(RESULT_OK, resultIntent)
    finish()
}
```

- `UploadFragment`에서 `registerForActivityResult()` 로 수신

```kotlin
private val cameraActivityLauncher = registerForActivityResult(
    ActivityResultContracts.StartActivityForResult()
) { result ->
    if (result.resultCode == Activity.RESULT_OK) {
        val uris = result.data
            ?.getStringArrayListExtra(CAMERA_RESULT_KEY)
            ?.map { Uri.parse(it) }
            ?: return@registerForActivityResult
        // UploadAdapter 에 추가
    }
}
```

---

## FeedFragment / 피드 기능

### 새로 만든 파일

| 파일 | 역할 |
|---|---|
| `ImagePagerAdapter.kt` | ViewPager2용 이미지 Adapter |
| `item_feed_image.xml` | ViewPager2 안 개별 이미지 레이아웃 |
| `IndexUpdateDelegate.kt` (interface) | iOS의 Protocol 역할, dot indicator 업데이트 |
| `PageIndicatorView.kt` | dot indicator 커스텀 뷰, IndexUpdateDelegate 구현체 |

### iOS ↔ Android 대응 관계

| iOS | Android |
|---|---|
| `protocol IndexUpdateDelegate` | `interface IndexUpdateDelegate` |
| `class PageControl: ..., IndexUpdateDelegate` | `class PageIndicatorView: ..., IndexUpdateDelegate` |
| `someObj.delegate = self` | `val delegate: IndexUpdateDelegate = binding.pageIndicatorView` |
| `delegate?.onUpdateIndex(i)` | `delegate.onUpdateIndex(i)` |
| `weak var` (ARC) | GC가 처리하므로 불필요 |

### ViewPager2 + dot indicator 연결 (FeedItemViewHolder)

```kotlin
fun bindData(item: FeedItemModel) {
    binding.imageViewPager.adapter = ImagePagerAdapter(item.images)
    binding.pageIndicatorView.setupDots(item.images.size)

    val delegate: IndexUpdateDelegate = binding.pageIndicatorView

    binding.imageViewPager.registerOnPageChangeCallback(
        object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                delegate.onUpdateIndex(position)
            }
        }
    )
}
```

### 댓글 토글 (ViewHolder 재사용 주의)

```kotlin
// ⚠️ ViewHolder 는 재사용(recycle)된다.
// 반드시 모델 상태(item.showReply)에 따라 매번 명시적으로 설정해야 함
binding.tempView.visibility =
    if (item.showReply) View.VISIBLE else View.GONE

binding.contentsShowReplyButton.setOnClickListener {
    item.showReply = !item.showReply
    bindData(item)
}
```

---

## 기타 학습 내용

### const val vs val

```kotlin
// const val: 컴파일 타임 상수, String/Int 등 기본형만 가능
const val CAMERA_RESULT_KEY = "selected_images"

// object 로 묶어서 관리 (연관된 상수가 여러 개일 때 권장)
object IntentKeys {
    const val CAMERA_RESULT = "selected_images"
    const val UPLOAD_URIS   = "uris"
}
```

### displayCutout insets (펀치홀 카메라 대응)

```kotlin
// systemBars 만으로는 펀치홀 카메라 영역을 피하지 못함
// displayCutout 을 or 로 합쳐야 함
val safeInsets = insets.getInsets(
    WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout()
)
view.setPadding(safeInsets.left, safeInsets.top, safeInsets.right, safeInsets.bottom)
```

### ConstraintLayout Guideline

```xml
<!-- 50% 지점에 세로 기준선 생성 -->
<androidx.constraintlayout.widget.Guideline
    android:id="@+id/vertical_guideline_50"
    android:orientation="vertical"
    app:layout_constraintGuide_percent="0.5" />

<!-- 뷰를 guideline 기준으로 배치 → 부모의 절반 크기 -->
<View
    android:layout_width="0dp"
    android:layout_height="0dp"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintEnd_toEndOf="@id/vertical_guideline_50" />
```
