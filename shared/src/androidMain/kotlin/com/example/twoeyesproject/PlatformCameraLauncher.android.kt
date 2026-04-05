package com.example.twoeyesproject

import android.graphics.Bitmap
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.graphics.decodeToImageBitmap
import java.io.ByteArrayOutputStream

class PlatformCameraLauncher(
    private val launcher: ActivityResultLauncher<Void?>
) : CameraLauncher {
    override fun launch() {
        launcher.launch(null)
    }
}

fun ComponentActivity.registerCameraLauncher(
    viewModel: PickImageViewModel
): PlatformCameraLauncher {
    val launcher = registerForActivityResult(
        ActivityResultContracts.TakePicturePreview()
    ) { bitmap: Bitmap? ->
        bitmap?.let {
            val stream = ByteArrayOutputStream()
            it.compress(Bitmap.CompressFormat.JPEG, 90, stream)
            val bitmap = stream.toByteArray().decodeToImageBitmap()

            viewModel.onImageCaptured(
                CapturedImage(
                    image = bitmap.asAndroidBitmap(),
                    width = bitmap.width,
                    height = bitmap.height
                )
            )
        }
    }

    return PlatformCameraLauncher(launcher)
}