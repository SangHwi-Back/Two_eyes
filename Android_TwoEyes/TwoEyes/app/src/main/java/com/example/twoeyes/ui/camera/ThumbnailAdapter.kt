package com.example.twoeyes.ui.camera

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.viewbinding.ViewBinding
import com.bumptech.glide.Glide
import com.example.twoeyes.databinding.ThumbnailEmptyViewBinding
import com.example.twoeyes.databinding.ThumbnailImageViewBinding

private const val THUMBNAIL_TYPE_EMPTY = 0
private const val THUMBNAIL_TYPE_ITEM = 1

class ThumbnailAdapter(
    private val onItemClick: (Uri) -> Unit
) : RecyclerView.Adapter<ThumbnailAdapter.ViewHolder>() {

    private var items: List<Uri> = emptyList()

    sealed class ViewHolder(binding: ViewBinding) : RecyclerView.ViewHolder(binding.root) {
        class Empty(binding: ThumbnailEmptyViewBinding) : ViewHolder(binding)
        class Item(binding: ThumbnailImageViewBinding) : ViewHolder(binding) {
            val imageView: ImageView = binding.thumbnailImageView
        }
    }

    override fun getItemViewType(position: Int) =
        if (items.isEmpty()) THUMBNAIL_TYPE_EMPTY else THUMBNAIL_TYPE_ITEM

    override fun getItemCount() = if (items.isEmpty()) 1 else items.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return if (viewType == THUMBNAIL_TYPE_EMPTY)
            ViewHolder.Empty(ThumbnailEmptyViewBinding.inflate(inflater, parent, false))
        else
            ViewHolder.Item(ThumbnailImageViewBinding.inflate(inflater, parent, false))
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        if (holder is ViewHolder.Item) {
            val item = items[position]
            Glide.with(holder.itemView).load(item).into(holder.imageView)
            holder.itemView.setOnClickListener { onItemClick(item) }
        }
    }

    fun updateList(newItems: List<Uri>) {
        val diff = DiffUtil.calculateDiff(object : DiffUtil.Callback() {
            override fun getOldListSize() = if (items.isEmpty()) 1 else items.size
            override fun getNewListSize() = if (newItems.isEmpty()) 1 else newItems.size
            override fun areItemsTheSame(oldPos: Int, newPos: Int) =
                items.isNotEmpty() && newItems.isNotEmpty() && items[oldPos] == newItems[newPos]
            override fun areContentsTheSame(oldPos: Int, newPos: Int) =
                items.isNotEmpty() && newItems.isNotEmpty() && items[oldPos] == newItems[newPos]
        })
        items = newItems
        diff.dispatchUpdatesTo(this)
    }
}