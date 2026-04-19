package com.example.twoeyesproject

import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import com.example.twoeyesproject.image.PhotoPickerLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import kotlinx.coroutines.runBlocking

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
        runBlocking {
            if (uri != null)
                viewModel.setImageFromSource(uri.buildUpon())
        }

    }

    return PlatformPhotoPickerLauncher(launcher)
}