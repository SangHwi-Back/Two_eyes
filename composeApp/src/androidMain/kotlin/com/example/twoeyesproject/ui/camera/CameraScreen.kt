package com.example.twoeyesproject.ui.camera

import android.Manifest
import android.content.ContentUris
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil3.compose.AsyncImage
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

@Composable
fun CameraScreen(
    viewModel: PickImageViewModel = viewModel(),
    onBack: () -> Unit,
    onNext: (uri1: String, uri2: String) -> Unit,
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val target by viewModel.target.collectAsStateWithLifecycle()

    // 앨범 URI 목록 (썸네일 캐러셀용)
    val albumUris = remember { mutableStateListOf<Uri>() }

    // 선택된 두 이미지의 URI 추적 (MergeScreen 이동 시 사용)
    var selectedUri1 by remember { mutableStateOf<Uri?>(null) }
    var selectedUri2 by remember { mutableStateOf<Uri?>(null) }

    // 카메라로 찍을 임시 파일 URI
    var pendingCameraUri by remember { mutableStateOf<Uri?>(null) }

    // ContentResolver에서 갤러리 URI 로드 (전체 Bitmap 대신 URI만 로드)
    fun loadAlbumUris() {
        scope.launch(Dispatchers.IO) {
            val uris = mutableListOf<Uri>()
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            else
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            val projection = arrayOf(MediaStore.Images.Media._ID)
            val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"
            context.contentResolver.query(collection, projection, null, null, sortOrder)?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    uris.add(ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id))
                }
            }
            withContext(Dispatchers.Main) {
                albumUris.clear()
                albumUris.addAll(uris)
            }
        }
    }

    // 썸네일 선택: URI → Bitmap 디코딩 후 ViewModel에 전달
    // PickImageViewModel의 setImage()/highlightImageView() 검증 지점
    fun onThumbnailSelected(uri: Uri) {
        scope.launch(Dispatchers.IO) {
            val bitmap = context.contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it)
            } ?: return@launch

            withContext(Dispatchers.Main) {
                // ViewModel이 어느 슬롯에 넣을지 미리 파악해 URI 추적
                val t = viewModel.target.value
                when {
                    t.leading.isHighlighted  -> selectedUri1 = uri
                    t.trailing.isHighlighted -> selectedUri2 = uri
                    t.leading.image == null  -> selectedUri1 = uri
                    t.trailing.image == null -> selectedUri2 = uri
                    else                     -> selectedUri1 = uri
                }
                viewModel.setImage(bitmap)
            }
        }
    }

    // 카메라 결과 처리
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
                    val t = viewModel.target.value
                    when {
                        t.leading.isHighlighted  -> selectedUri1 = uri
                        t.trailing.isHighlighted -> selectedUri2 = uri
                        t.leading.image == null  -> selectedUri1 = uri
                        t.trailing.image == null -> selectedUri2 = uri
                        else                     -> selectedUri1 = uri
                    }
                    viewModel.setImage(bitmap)
                    albumUris.add(0, uri)
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
            android.content.Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, uri)
            }
        )
    }

    // 카메라 권한 요청
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) launchCamera()
    }

    // 앨범 권한 요청
    val albumPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val granted = permissions[Manifest.permission.READ_MEDIA_IMAGES] == true ||
            permissions[Manifest.permission.READ_EXTERNAL_STORAGE] == true ||
            (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
                permissions[Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED] == true)
        if (granted) loadAlbumUris()
    }

    // 일부 허용(Android 14+) 처리용 런처
    val pickImageLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val uri = result.data?.data
        if (result.resultCode == android.app.Activity.RESULT_OK && uri != null) {
            onThumbnailSelected(uri)
            albumUris.add(0, uri)
        }
    }

    fun requestAlbumPermission() {
        val hasFullAccess = context.checkSelfPermission(Manifest.permission.READ_MEDIA_IMAGES) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED ||
            context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED

        when {
            hasFullAccess -> loadAlbumUris()
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            context.checkSelfPermission(Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED) ==
                android.content.pm.PackageManager.PERMISSION_GRANTED ->
                pickImageLauncher.launch(Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" })
            else -> albumPermissionLauncher.launch(
                when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE ->
                        arrayOf(Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU ->
                        arrayOf(Manifest.permission.READ_MEDIA_IMAGES)
                    else ->
                        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
                }
            )
        }
    }

    Column(modifier = Modifier.fillMaxSize()) {
        // 상단: 뒤로가기 버튼
        Row(
            modifier = Modifier.fillMaxWidth().padding(8.dp),
            horizontalArrangement = Arrangement.End
        ) {
            TextButton(onClick = onBack) { Text("닫기") }
        }

        // 중앙: 선택된 이미지 두 슬롯 (PickImageViewModel.target 반영)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Leading 슬롯
            SelectedImageSlot(
                image = target.leading.image?.asImageBitmap(),
                isHighlighted = target.leading.isHighlighted,
                modifier = Modifier.weight(1f).fillMaxHeight(),
                onClick = { viewModel.highlightImageView(target.leading) }
            )
            // Trailing 슬롯
            SelectedImageSlot(
                image = target.trailing.image?.asImageBitmap(),
                isHighlighted = target.trailing.isHighlighted,
                modifier = Modifier.weight(1f).fillMaxHeight(),
                onClick = { viewModel.highlightImageView(target.trailing) }
            )
        }

        // 썸네일 캐러셀
        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .padding(horizontal = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(albumUris) { uri ->
                AsyncImage(
                    model = uri,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .width(100.dp)
                        .fillMaxHeight()
                        .clickable { onThumbnailSelected(uri) }
                )
            }
        }

        // 하단 버튼: 카메라, 앨범, 다음
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("사진 추가", style = MaterialTheme.typography.titleMedium)
            Row(
                modifier = Modifier.padding(top = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(onClick = {
                    val hasCamera = context.checkSelfPermission(Manifest.permission.CAMERA) ==
                        android.content.pm.PackageManager.PERMISSION_GRANTED
                    if (hasCamera) launchCamera()
                    else cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                }) { Text("카메라") }

                var showAlbumMenu by remember { mutableStateOf(false) }
                Box {
                    Button(onClick = { showAlbumMenu = true }) { Text("앨범") }
                    DropdownMenu(
                        expanded = showAlbumMenu,
                        onDismissRequest = { showAlbumMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("앨범에서 선택") },
                            onClick = {
                                showAlbumMenu = false
                                pickImageLauncher.launch(
                                    Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" }
                                )
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("전체 불러오기") },
                            onClick = {
                                showAlbumMenu = false
                                requestAlbumPermission()
                            }
                        )
                    }
                }

                Button(
                    onClick = {
                        val u1 = selectedUri1
                        val u2 = selectedUri2
                        if (u1 != null && u2 != null) onNext(u1.toString(), u2.toString())
                    },
                    enabled = selectedUri1 != null && selectedUri2 != null
                ) { Text("다음") }
            }
        }
    }
}

@Composable
private fun SelectedImageSlot(
    image: androidx.compose.ui.graphics.ImageBitmap?,
    isHighlighted: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    val borderColor = if (isHighlighted) Color.Red else Color.Gray
    Box(
        modifier = modifier
            .border(2.dp, borderColor, RoundedCornerShape(8.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(8.dp))
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        if (image != null) {
            androidx.compose.foundation.Image(
                bitmap = image,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        } else {
            Text("+", style = MaterialTheme.typography.displaySmall, color = Color.Gray)
        }
    }
}
