package com.example.twoeyes

import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.NavController
import androidx.navigation.NavOptions
import androidx.navigation.fragment.NavHostFragment
import com.example.twoeyes.ui.camera.CameraFragment
import com.example.twoeyes.ui.feed.FeedFragment
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.floatingactionbutton.FloatingActionButton

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

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                for (fragment in supportFragmentManager.fragments) {
                    if (fragment is CameraFragment) {
                        bottomNavigationView.selectedItemId = R.id.camera_fragment
                        break
                    } else if (fragment is FeedFragment) {
                        bottomNavigationView.selectedItemId = R.id.feed_fragment
                        break
                    }
                }
                bottomNavigationView.selectedItemId = R.id.feed_fragment
            }
        })
    }
}