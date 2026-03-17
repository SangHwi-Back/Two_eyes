package com.example.twoeyes

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.ViewGroup
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.example.twoeyes.ui.camera.CameraActivity
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import androidx.core.net.toUri
import com.example.twoeyes.ui.camera.CAMERA_RESULT_CODE
import com.example.twoeyes.ui.upload.UPLOAD_TARGET_URIS

class MainActivity : AppCompatActivity() {
    private lateinit var bottomNavigationView: BottomNavigationView
    private lateinit var cameraFloatingButton: FloatingActionButton
    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContentView(R.layout.activity_main)

        bottomNavigationView = findViewById(R.id.bottomNavigationView)
        cameraFloatingButton = findViewById(R.id.fab_camera)

        val navHostFragment = supportFragmentManager
            .findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController
        bottomNavigationView.setupWithNavController(navController)

        cameraFloatingButton.setOnClickListener {
            cameraActivityLauncher.launch(Intent(this, CameraActivity::class.java))
        }
    }

    private val cameraActivityLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            val uris = result.data
                ?.getStringArrayExtra(CAMERA_RESULT_CODE)
                ?.map { it.toUri() }
                ?: return@registerForActivityResult

            val bundle = Bundle().apply {
                putStringArrayList(UPLOAD_TARGET_URIS, ArrayList(uris.map { it.toString() }))
            }
            navController.navigate(R.id.upload_fragment, bundle)
        }
    }
}