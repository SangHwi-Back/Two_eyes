package com.example.twoeyes.ui.upload

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.net.toUri
import com.example.twoeyes.R
import com.example.twoeyes.databinding.FragmentFeedBinding
import com.example.twoeyes.databinding.FragmentUploadBinding

const val UPLOAD_TARGET_URIS = "uris"
class UploadFragment : Fragment() {
    lateinit var adapter: UploadAdapter
    lateinit var binding: FragmentUploadBinding

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val uris = arguments
            ?.getStringArrayList(UPLOAD_TARGET_URIS)
            ?.map { it.toUri() }
            ?: emptyList()

        adapter.setListData(uris.map { UploadListItemModel(it) })
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        adapter = UploadAdapter(layoutInflater)
        binding = FragmentUploadBinding.inflate(inflater, container, false)
        // Inflate the layout for this fragment
        return binding.root
    }
}