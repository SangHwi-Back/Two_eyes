package com.example.twoeyesproject.ui.camera

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowForward
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.outlined.CameraAlt
import androidx.compose.material.icons.outlined.Close
import androidx.compose.material.icons.outlined.PhotoLibrary
import androidx.compose.material.icons.outlined.RestoreFromTrash
import androidx.compose.material.icons.outlined.TouchApp
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil3.compose.AsyncImage
import com.example.twoeyesproject.image.CapturedImage
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

// ── Dashed border Modifier (iOS stroke + dash 효과 재현) ──────────────────────
private fun Modifier.dashedBorder(
    color: Color,
    cornerRadius: Dp = 8.dp,
    strokeWidth: Dp = 1.dp,
    dashLength: Dp = 6.dp,
    gapLength: Dp = 10.dp,
): Modifier = this.drawBehind {
    drawRoundRect(
        color = color,
        style = Stroke(
            width = strokeWidth.toPx(),
            pathEffect = PathEffect.dashPathEffect(
                floatArrayOf(dashLength.toPx(), gapLength.toPx())
            )
        ),
        cornerRadius = CornerRadius(cornerRadius.toPx())
    )
}

// ── CameraScreen ──────────────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PickImageScreen(
    viewModel: PickImageViewModel = viewModel(),
    onBack: () -> Unit,
    onNext: (uri1: String, uri2: String) -> Unit,
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val target by viewModel.target.collectAsStateWithLifecycle()

    // 갤러리 목록은 ViewModel의 imageSources StateFlow로 수집
    val imageSources by viewModel.imageSources.collectAsStateWithLifecycle()

    // MergeScreen 이동용 URI 추적 (ViewModel에는 저장소 없음)
    var pendingCameraUri by remember { mutableStateOf<Uri?>(null) }

    val goNextEnabled = target.leading.image != null
            && target.trailing.image != null
            && imageSources.size >= 2
    val thumbnailHeight = 190.dp

    // ── selectedUri 슬롯 결정 헬퍼 ────────────────────────────────────────────
//    fun resolveTargetSlot(uri: Uri) {
//        runBlocking {
//            viewModel.setImageFromSource(uri.buildUpon())
//        }
//    }

    // ── 썸네일 탭: ViewModel이 URI를 직접 decode해서 슬롯에 배치 ──────────────
    fun onThumbnailSelected(imageSource: Uri.Builder) {
//        resolveTargetSlot(imageSource.build())
        scope.launch { viewModel.setImageFromSource(imageSource) }
    }

    // ── 카메라 ─────────────────────────────────────────────────────────────────
    val takePictureLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val uri = pendingCameraUri
        pendingCameraUri = null
        if (result.resultCode == android.app.Activity.RESULT_OK && uri != null) {
            scope.launch(Dispatchers.IO) {
                val bitmap = context.contentResolver.openInputStream(uri)?.use {
                    BitmapFactory.decodeStream(it)
                } ?: return@launch
                withContext(Dispatchers.Main) {
//                    resolveTargetSlot(uri)
                    viewModel.setCapturedImage(
                        CapturedImage(image = bitmap, width = bitmap.width, height = bitmap.height)
                    )
                }
            }
        }
    }
    fun launchCamera() {
        val imageFile = File(
            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES),
            "camera_${System.currentTimeMillis()}.jpg"
        )
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", imageFile)
        pendingCameraUri = uri
        takePictureLauncher.launch(
            Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply { putExtra(MediaStore.EXTRA_OUTPUT, uri) }
        )
    }
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted -> if (isGranted) launchCamera() }

    val permissionReadImage: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
        Manifest.permission.READ_MEDIA_IMAGES
    else
        Manifest.permission.READ_EXTERNAL_STORAGE
    val pickImagePermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
        Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED
    else
        ""
    // ── 앨범에서 1장 선택 (Pick 버튼): PlatformPhotoPickerLauncher와 동일한 로직 ──
    // PickVisualMedia → ImageDecoder().decode() → viewModel.setCapturedImage()
    val pickImageLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        uri?.let {
//            resolveTargetSlot(it)
            scope.launch {
                val decoder = ImageDecoder()
                val decodedImage = decoder.decode(it.buildUpon())
                viewModel.setCapturedImage(CapturedImage(
                    image = decodedImage,
                    width = decodedImage.width,
                    height = decodedImage.height
                ))
            }
        }
    }
    // ── 전체 불러오기 권한 요청: 허가 후 viewModel.loadAllImages() ─────────────
    val pickImagePermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions[permissionReadImage] ?: false || permissions[pickImagePermission] ?: false)
            pickImageLauncher.launch(PickVisualMediaRequest())
        else
            Toast.makeText(context, "Permission Not granted", Toast.LENGTH_LONG).show()
    }
    fun requestAlbumPermission() = when {
        // Version low
        Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ->
            Toast.makeText(context, "Version is too low!", Toast.LENGTH_LONG).show()
        // Already granted
        context.checkSelfPermission(permissionReadImage) == PackageManager.PERMISSION_GRANTED
                || context.checkSelfPermission(pickImagePermission) == PackageManager.PERMISSION_GRANTED ->
            pickImageLauncher.launch(PickVisualMediaRequest())
        // Needed to get granted by user
        else ->
            pickImagePermissionLauncher.launch(arrayOf(permissionReadImage, pickImagePermission))
    }
    // ── UI ────────────────────────────────────────────────────────────────────
    Scaffold(
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Outlined.Close, contentDescription = "닫기")
                    }
                }
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
        ) {

            // ── 이미지 슬롯 (iOS: HStack + aspectRatio(0.9)) ─────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(0.9f)
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                ImageSlot(
                    imageViewModel = target.leading,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    onClick = {
                        when (it) {
                            CameraScreenTapType.Highlight -> viewModel.highlightImageView(target.leading)
                            CameraScreenTapType.Delete -> viewModel.deleteImage(target.leading)
                        }
                    }
                )
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.padding(horizontal = 6.dp)
                )
                ImageSlot(
                    imageViewModel = target.trailing,
                    modifier = Modifier.weight(1f).fillMaxHeight(),
                    onClick = {
                        when (it) {
                            CameraScreenTapType.Highlight -> viewModel.highlightImageView(target.trailing)
                            CameraScreenTapType.Delete -> viewModel.deleteImage(target.trailing)
                        }
                    }
                )
            }

            // ── 썸네일 캐러셀: viewModel.imageSources 수집 (iOS: 비어있으면 height=0) ──
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(if (imageSources.isEmpty()) 0.dp else thumbnailHeight)
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(imageSources) { imageSource ->
                    AsyncImage(
                        model = imageSource.build(),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .width(120.dp)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(8.dp))
                            .clickable { onThumbnailSelected(imageSource) }
                    )
                }
            }

            // ── 하단 버튼 바 (iOS: Camera / Pick / GetAll / Next, Spacer 균등 배분) ──
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(80.dp)
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                BottomButton(
                    icon = { Icon(Icons.Outlined.CameraAlt, contentDescription = null) },
                    label = "Camera",
                    onClick = {
                        val hasCamera = context.checkSelfPermission(Manifest.permission.CAMERA) ==
                            PackageManager.PERMISSION_GRANTED
                        if (hasCamera) launchCamera()
                        else cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                    }
                )
                Spacer(modifier = Modifier.weight(1f))
                BottomButton(
                    icon = { Icon(Icons.Outlined.TouchApp, contentDescription = null) },
                    label = "Pick",
                    onClick = { pickImageLauncher.launch(PickVisualMediaRequest()) }
                )
                Spacer(modifier = Modifier.weight(1f))
                BottomButton(
                    icon = { Icon(Icons.Outlined.PhotoLibrary, contentDescription = null) },
                    label = "GetAll",
                    onClick = { requestAlbumPermission() }
                )
                Spacer(modifier = Modifier.weight(1f))
                BottomButton(
                    icon = {
                        Icon(
                            imageVector = Icons.AutoMirrored.Outlined.ArrowForward,
                            contentDescription = null,
                            tint = if (goNextEnabled)
                                MaterialTheme.colorScheme.onSurface
                            else
                                MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
                        )
                    },
                    label = "Next",
                    enabled = goNextEnabled,
                    onClick = {
                        if (imageSources.size < 2) return@BottomButton
                        onNext(imageSources[0].toString(), imageSources[1].toString())
                    }
                )
            }
        }
    }
}

enum class CameraScreenTapType {
    Highlight, Delete
}

// ── BottomButton ──────────────────────────────────────────────────────────────
// iOS의 BottomButtonImage: VStack { 아이콘 + 텍스트 } + glassEffect 대응
@Composable
private fun BottomButton(
    icon: @Composable () -> Unit,
    label: String,
    enabled: Boolean = true,
    onClick: () -> Unit,
) {
    Surface(
        onClick = onClick,
        enabled = enabled,
        shape = RoundedCornerShape(8.dp),
        tonalElevation = 2.dp,
        modifier = Modifier.size(72.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            icon()
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = if (enabled)
                    MaterialTheme.colorScheme.onSurface
                else
                    MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
            )
        }
    }
}

// ── ImageSlot ─────────────────────────────────────────────────────────────────
// iOS의 getImageView 역할: 점선 테두리 + 탭 가능 영역 전체 커버
@Composable
private fun ImageSlot(
    imageViewModel: PickImageViewModel.ImageViewModel,
    modifier: Modifier = Modifier,
    onClick: (CameraScreenTapType) -> Unit,
) {
    val strokeColor = if (imageViewModel.isHighlighted)
        MaterialTheme.colorScheme.error
    else
        MaterialTheme.colorScheme.outline

    val bitmap = imageViewModel.image?.asImageBitmap()

    Box(
        modifier = modifier
            .dashedBorder(color = strokeColor, cornerRadius = 8.dp)
            .clip(RoundedCornerShape(8.dp))
            .clickable { onClick(CameraScreenTapType.Highlight) },
        contentAlignment = Alignment.Center
    ) {
        if (bitmap != null) {
            Image(
                bitmap = bitmap,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
            IconButton(
                onClick = { onClick(CameraScreenTapType.Delete) },
                modifier = Modifier
                    .size(42.dp)
                    .align(Alignment.TopEnd)
            ) {
                Icon(imageVector = Icons.Outlined.RestoreFromTrash, contentDescription = "사진 지우기")
            }
        }
    }
}
