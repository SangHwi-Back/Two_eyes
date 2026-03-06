package com.example.twoeyes.ui.camera

import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.fragment.app.Fragment
import com.bumptech.glide.Glide
import com.example.twoeyes.R

// 이미지를 표시하는 Fragment
class PictureFragment : Fragment() {
    private var imageData: Any? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            imageData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelable(ARG_IMAGE, Bitmap::class.java)
                    ?: it.getParcelable(ARG_IMAGE, android.net.Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                it.getParcelable<Bitmap>(ARG_IMAGE)
                    ?: @Suppress("DEPRECATION")
                    it.getParcelable<android.net.Uri>(ARG_IMAGE)
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_picture, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val imageView = view.findViewById<ImageView>(R.id.picture_image_view)

        when (val data = imageData) {
            is Bitmap -> imageView.setImageBitmap(data)
            is android.net.Uri -> Glide.with(this).load(data).into(imageView)
            else -> imageView.setImageResource(android.R.drawable.ic_menu_gallery)
        }
    }

    companion object {
        private const val ARG_IMAGE = "image_data"

        fun newInstance(imageData: Any): PictureFragment {
            return PictureFragment().apply {
                arguments = Bundle().apply {
                    when (imageData) {
                        is Bitmap -> putParcelable(ARG_IMAGE, imageData)
                        is android.net.Uri -> putParcelable(ARG_IMAGE, imageData)
                    }
                }
            }
        }
    }
}