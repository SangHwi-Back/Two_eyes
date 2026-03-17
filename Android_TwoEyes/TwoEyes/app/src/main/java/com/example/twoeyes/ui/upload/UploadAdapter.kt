package com.example.twoeyes.ui.upload

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView

class UploadAdapter(
    private val layoutInflater: LayoutInflater
): RecyclerView.Adapter<UploadAdapter.UploadViewHolder>() {

    fun setListData(list: List<UploadListItemModel>) {

    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): UploadViewHolder {
        TODO("Not yet implemented")
    }

    override fun onBindViewHolder(holder: UploadViewHolder, position: Int) {
        TODO("Not yet implemented")
    }

    override fun getItemCount(): Int {
        TODO("Not yet implemented")
    }

    class UploadViewHolder(contentView: View): RecyclerView.ViewHolder(contentView) {

    }
}

