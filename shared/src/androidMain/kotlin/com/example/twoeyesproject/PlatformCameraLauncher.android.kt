package com.example.twoeyesproject

import android.net.Uri
import android.os.Environment
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.FileProvider
import com.example.twoeyesproject.image.CameraLauncher
import com.example.twoeyesproject.image.PickImageViewModel
import java.io.File

class PlatformCameraLauncher(
    private val context: android.content.Context,
    private val launcher: ActivityResultLauncher<Uri>
) : CameraLauncher {
    var pendingUri: Uri? = null

    override fun launch() {
        val imageFile = File(
            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES),
            "camera_${System.currentTimeMillis()}.jpg"
        )
        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            imageFile
        )
        pendingUri = uri
        launcher.launch(uri)
    }
}

fun ComponentActivity.registerCameraLauncher(
    viewModel: PickImageViewModel
): PlatformCameraLauncher {
    lateinit var cameraLauncher: PlatformCameraLauncher

    val launcher = registerForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success: Boolean ->
        if (!success) return@registerForActivityResult
        val uri = cameraLauncher.pendingUri ?: return@registerForActivityResult
        cameraLauncher.pendingUri = null

        viewModel.setCameraImage(uri.buildUpon())
    }

    cameraLauncher = PlatformCameraLauncher(applicationContext, launcher)
    return cameraLauncher
}
