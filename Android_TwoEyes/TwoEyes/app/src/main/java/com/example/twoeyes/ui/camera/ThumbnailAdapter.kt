package com.example.twoeyes.ui.camera

import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.R
import com.example.twoeyes.databinding.ThumbnailImageViewBinding

class ThumbnailAdapter(
    private val onItemClick: (Uri) -> Unit
) : RecyclerView.Adapter<ThumbnailAdapter.ViewHolder>() {
    private var items: List<Uri> = emptyList()
    class ViewHolder(
        binding: ThumbnailImageViewBinding
    ) : RecyclerView.ViewHolder(binding.root) {
        val imageView = binding.thumbnailImageView
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ThumbnailImageViewBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        Glide.with(holder.itemView).load(item).into(holder.imageView)
        holder.itemView.setOnClickListener { onItemClick(item) }
    }
    override fun getItemCount(): Int = items.size
    fun updateList(newItems: List<Uri>) {
        items = newItems
        notifyDataSetChanged()
    }
}