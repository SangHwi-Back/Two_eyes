package com.example.twoeyes.ui.camera

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.R
import com.google.android.material.button.MaterialButton
import kotlinx.coroutines.launch

class CameraActivity : AppCompatActivity() {
    private val viewModel: CameraViewModel by viewModels()
    private lateinit var recyclerView: RecyclerView
    private lateinit var thumbnailAdapter: ThumbnailAdapter
    // Android 13 이상: READ_MEDIA_IMAGES 사용
    // Android 12 이하: READ_EXTERNAL_STORAGE 사용
    private val currentAlbumPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
        Manifest.permission.READ_MEDIA_IMAGES else Manifest.permission.READ_EXTERNAL_STORAGE
    private fun isGranted(permission: String) = ContextCompat.checkSelfPermission(
        this, permission) == PackageManager.PERMISSION_GRANTED
    private fun isGrantedAlbumPermission() = isGranted(currentAlbumPermission)
    private fun isGrantedCameraPermission() = isGranted(Manifest.permission.CAMERA)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_camera)

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main_camera)) { view, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            view.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        recyclerView = findViewById(R.id.image_carousel_recycler_view)
        recyclerView.addItemDecoration(object : RecyclerView.ItemDecoration() {
            override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
                outRect.right = resources.getDimensionPixelSize(R.dimen.fab_margin)
            }
        })
        thumbnailAdapter = ThumbnailAdapter { viewModel.selectImage(it) }
        recyclerView.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        recyclerView.adapter = thumbnailAdapter

        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.items.collect { itemList ->
                    thumbnailAdapter.updateList(itemList)
                }
            }
        }
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.selectedImages.collect { selected ->
                    for ((index, select) in selected.withIndex()) {
                        Glide
                            .with(findViewById(R.id.selected_image_linear_layout))
                            .load(select)
                            .into(findViewById(if (index == 0) R.id.selected_image_start else R.id.selected_image_end))
                    }
                }
            }
        }

        findViewById<MaterialButton>(R.id.button_back)
            .setOnClickListener { finish() }
        findViewById<Button>(R.id.show_camera_button)
            .setOnClickListener { requestCameraPermission() }
        findViewById<Button>(R.id.show_album_button)
            .setOnClickListener { requestAlbumPermission() }
    }
    override fun finish() {
        super.finish()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
            overrideActivityTransition(
                OVERRIDE_TRANSITION_CLOSE, 0, R.anim.slide_down)
        else
            @Suppress("DEPRECATION")
            overridePendingTransition(0, R.anim.slide_down)
    }
    // 카메라로 사진 찍기
    private val takePictureLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val imageBitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            result.data?.extras?.getParcelable("data", Bitmap::class.java)
        else
            @Suppress("DEPRECATION")
            result.data?.extras?.getParcelable("data")

        if (result.resultCode == RESULT_OK && imageBitmap != null)
            viewModel.addItem(imageBitmap)
        else
            showToast("Failed to get image")
    }
    // 앨범에서 이미지 선택
    private val pickImageLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val uri = result.data?.data
        if (result.resultCode == RESULT_OK && uri != null)
            viewModel.addItem(uri)
        else
            showToast("Failed to get image URI")
    }
    // 카메라 권한 요청
    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (isGranted) takePictureLauncher.launch(intent) else showToast("Camera permission not granted")
    }
    // 앨범 권한 요청
    private val albumPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" }
        if (isGranted) pickImageLauncher.launch(intent) else showToast("Album permission not granted")
    }
    private fun showToast(message: String) = Toast
        .makeText(this, message, Toast.LENGTH_LONG).show()
    private fun requestCameraPermission() {
        // 권한이 이미 있으면 바로 카메라 실행. 권한이 없으면 권한 요청
        if (isGrantedCameraPermission())
            takePictureLauncher.launch(Intent(MediaStore.ACTION_IMAGE_CAPTURE))
        else
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
    }
    private fun requestAlbumPermission() {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" }
        // 권한이 이미 있으면 바로 앨범 실행. 권한이 없으면 권한 요청
        if (isGrantedAlbumPermission())
            pickImageLauncher.launch(intent)
        else
            albumPermissionLauncher.launch(currentAlbumPermission)
    }
}