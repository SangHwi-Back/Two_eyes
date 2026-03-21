package com.example.twoeyes.ui.camera.merge

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.example.twoeyes.databinding.FragmentCameraMergeBinding
import kotlinx.coroutines.launch

class CameraMergeFragment: Fragment() {
    private val viewModel: MergeViewModel by viewModels()
    private lateinit var binding: FragmentCameraMergeBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentCameraMergeBinding.inflate(inflater)
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.mergeTrigger.collect { bitmap ->
                binding.previewImageView.setImageBitmap(bitmap)
            }
        }
        return binding.root
    }
}