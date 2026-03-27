package com.example.twoeyes.ui.camera

import android.Manifest
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.os.bundleOf
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.R
import com.example.twoeyes.databinding.FragmentCameraBinding
import com.example.twoeyes.ui.camera.merge.CAMERA_MERGE_MODEL
import com.example.twoeyes.ui.camera.merge.CameraMergeModel
import kotlinx.coroutines.launch
import java.io.File

class CameraFragment : Fragment() {

    private var pendingImageUri: Uri? = null
    private lateinit var binding: FragmentCameraBinding
    private val viewModel: CameraViewModel by viewModels()
    private lateinit var thumbnailAdapter: ThumbnailAdapter
    private fun isGranted(permission: String) = ContextCompat.checkSelfPermission(
        requireContext(), permission) == PackageManager.PERMISSION_GRANTED

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = FragmentCameraBinding.inflate(inflater)
        val isLandscape = resources.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
        setupCommonViews(isLandscape)
        
        return binding.root
    }
    private fun setupCommonViews(isLandscape: Boolean) {
        ViewCompat.setOnApplyWindowInsetsListener(binding.fragmentCamera) { view, insets ->
            val safeInsets = insets.getInsets(
                WindowInsetsCompat.Type.systemBars()
                        or WindowInsetsCompat.Type.displayCutout())
            view.setPadding(safeInsets.left, safeInsets.top, safeInsets.right, safeInsets.bottom)
            insets
        }
        binding.imageCarouselRecyclerView.addItemDecoration(object : RecyclerView.ItemDecoration() {
            override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
                outRect.right = resources.getDimensionPixelSize(R.dimen.fab_margin)
            }
        })
        thumbnailAdapter = ThumbnailAdapter { viewModel.selectImage(it) }
        binding.imageCarouselRecyclerView.layoutManager = LinearLayoutManager(
            requireContext(),
            if (isLandscape) LinearLayoutManager.VERTICAL else LinearLayoutManager.HORIZONTAL,
            false
        )
        binding.imageCarouselRecyclerView.adapter = thumbnailAdapter
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
                    for ((index, select) in selected.filterNotNull().withIndex()) {
                        Glide
                            .with(binding.selectedImageLayout)
                            .load(select)
                            .into(if (index == 0) binding.selectedImageStart else binding.selectedImageEnd)
                    }
                }
            }
        }
        binding.buttonBack.setOnClickListener { finishWithResult() }
        binding.showCameraButton.setOnClickListener { requestCameraPermission() }
        binding.showAlbumButton.setOnClickListener { requestAlbumPermission() }
        binding.nextButton.setOnClickListener {
            val selected = viewModel.selectedImages.value.filterNotNull()

            if (selected.size < 2) {
                showToast("이미지를 2장 선택해주세요.")
                return@setOnClickListener
            }
            findNavController().navigate(
                R.id.action_camera_fragment_to_camera_merge_fragment,
                bundleOf(CAMERA_MERGE_MODEL to
                        CameraMergeModel(selected[0], selected[1]))
            )
        }
    }
    private fun finishWithResult() {
        findNavController().popBackStack(R.id.camera_fragment, false)
    }
    // 카메라로 사진 찍기
    private val takePictureLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val uri = pendingImageUri
        pendingImageUri = null

        if (result.resultCode == RESULT_OK && uri != null)
            viewModel.addItem(uri)
        else
            showToast("Failed to get image")
    }
    private fun requestAlbumPermission() {
        when {
            // 전체 허용 이미 있음
            isGranted(Manifest.permission.READ_MEDIA_IMAGES) ||
            isGranted(Manifest.permission.READ_EXTERNAL_STORAGE) ->
                viewModel.loadAllImages(requireContext().contentResolver)
            // 일부 허용 이미 있음 (Android 14+)
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            isGranted(Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED) ->
                pickImageLauncher.launch(Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" })
            // 권한 없음 → 요청
            else -> albumPermissionLauncher.launch(
                when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE ->
                        arrayOf(Manifest.permission.READ_MEDIA_IMAGES,
                                Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU ->
                        arrayOf(Manifest.permission.READ_MEDIA_IMAGES)
                    else ->
                        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
                }
            )
        }
    }
    // 앨범 권한 요청
    private val albumPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        when {
            permissions[Manifest.permission.READ_MEDIA_IMAGES] == true ||
            permissions[Manifest.permission.READ_EXTERNAL_STORAGE] == true ->
                viewModel.loadAllImages(requireContext().contentResolver)          // 전체 허용
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            permissions[Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED] == true ->
                pickImageLauncher.launch(                          // 일부 허용
                    Intent(Intent.ACTION_GET_CONTENT).apply { type = "image/*" })
            else -> showToast("Album permission not granted")      // 거부
        }
    }
    // 앨범에서 이미지 선택
    private val pickImageLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val uri = result.data?.data
        if (result.resultCode == RESULT_OK && uri != null)
            viewModel.copyToAppStorage(requireContext(), uri)
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
    private fun requestCameraPermission() {
        // 권한이 이미 있으면 바로 카메라 실행. 권한이 없으면 권한 요청
        if (isGranted(Manifest.permission.CAMERA))
            launchCamera()
        else
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
    }
    private fun launchCamera() {
        val imageFile = File(
            requireContext().getExternalFilesDir(Environment.DIRECTORY_PICTURES),
            "camera_${System.currentTimeMillis()}.jpg"
        )
        val imageUri = FileProvider.getUriForFile(
            requireContext(),
            "${requireContext().packageName}.fileprovider",
            imageFile
        )
        pendingImageUri = imageUri

        takePictureLauncher.launch(
            Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, imageUri)
            }
        )
    }
    private fun showToast(message: String) = Toast
        .makeText(requireContext(), message, Toast.LENGTH_LONG).show()
}