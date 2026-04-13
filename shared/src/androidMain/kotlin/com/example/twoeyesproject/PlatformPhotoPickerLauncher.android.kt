package com.example.twoeyesproject

import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.viewModelScope
import com.example.twoeyesproject.image.CapturedImage
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.PhotoPickerLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import com.example.twoeyesproject.platformspecific.ImageSource
import kotlinx.coroutines.launch

class PlatformPhotoPickerLauncher(
    private val launcher: ActivityResultLauncher<PickVisualMediaRequest>
): PhotoPickerLauncher {
    override fun launch() {
        launcher.launch(PickVisualMediaRequest())
    }
}

fun ComponentActivity.registerPhotoPickerLauncher(
    viewModel: PickImageViewModel
) : PlatformPhotoPickerLauncher {
    val launcher = registerForActivityResult(
        ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        uri?.let {
            viewModel.viewModelScope.launch {
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

    return PlatformPhotoPickerLauncher(launcher)
}