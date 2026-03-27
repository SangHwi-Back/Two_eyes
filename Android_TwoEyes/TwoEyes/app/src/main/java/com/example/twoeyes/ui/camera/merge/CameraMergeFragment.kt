package com.example.twoeyes.ui.camera.merge

import android.os.Bundle
import android.util.SizeF
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.example.twoeyes.databinding.FragmentCameraMergeBinding
import kotlinx.coroutines.launch
import android.net.Uri
import android.os.Parcelable // Parcelable 임포트
import kotlinx.parcelize.Parcelize // Parcelize 임포트
import kotlinx.serialization.Serializable

const val CAMERA_MERGE_MODEL = "modelCameraMerge"

class CameraMergeFragment: Fragment() {
    private val viewModel: MergeViewModel by viewModels {
        val uri1 = requireArguments().getString(ARG_URI_1)!!
        val uri2 = requireArguments().getString(ARG_URI_2)!!
        val canvasSize = SizeF(
            resources.displayMetrics.widthPixels.toFloat(),
            resources.displayMetrics.heightPixels.toFloat() * 0.6f  // 캔버스 영역 비율
        )
        MergeViewModelFactory(requireContext(), uri1, uri2, canvasSize)
    }
    private lateinit var binding: FragmentCameraMergeBinding

    companion object {
        private const val ARG_URI_1 = "uri_1"
        private const val ARG_URI_2 = "uri_2"
        fun newInstance(uri1: String, uri2: String) = CameraMergeFragment().apply {
            arguments = bundleOf(ARG_URI_1 to uri1, ARG_URI_2 to uri2)
        }
    }

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

@Serializable
@Parcelize
data class CameraMergeModel(
    val uri1: Uri,
    val uri2: Uri,
) : Parcelable