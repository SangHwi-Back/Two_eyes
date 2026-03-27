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
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import androidx.core.net.toUri
import androidx.navigation.NavOptions

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
        bottomNavigationView.setOnItemSelectedListener { item ->
            navController.navigate(
                item.itemId,
                null,
                NavOptions.Builder()
                    .setPopUpTo(navController.graph.startDestinationId, false)
                    .build()
            )
            true
        }

        cameraFloatingButton.setOnClickListener {
            navController.navigate(
                R.id.camera_fragment,
                null,
                NavOptions.Builder()
                    .setPopUpTo(navController.graph.startDestinationId, false)
                    .build()
            )
        }
    }
}