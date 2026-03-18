package com.example.twoeyes.ui.feed.detail

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.net.toUri
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.R
import com.example.twoeyes.databinding.ItemFeedDetailContentBinding
import com.example.twoeyes.databinding.ItemFeedDetailHeaderBinding
import com.example.twoeyes.databinding.ItemFeedDetailImageBinding

class FeedDetailAdapter(
    private val items: List<ListItem>
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    companion object {
        const val VIEW_TYPE_HEADER = 0
        const val VIEW_TYPE_IMAGE = 1
        const val VIEW_TYPE_CONTENT = 2
    }
    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): RecyclerView.ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return when (viewType) {
            VIEW_TYPE_HEADER -> HeaderViewHolder(ItemFeedDetailHeaderBinding
                .inflate(inflater, parent, false))
            VIEW_TYPE_IMAGE -> ImageViewHolder(ItemFeedDetailImageBinding
                .inflate(inflater, parent, false))
            VIEW_TYPE_CONTENT -> ContentViewHolder(ItemFeedDetailContentBinding
                .inflate(inflater, parent, false))
            else -> throw IllegalArgumentException("Unknown view type")
        }
    }
    override fun onBindViewHolder(
        viewHolder: RecyclerView.ViewHolder,
        position: Int
    ) {
        when (val item = items[position]) {
            is ListItem.Header -> (viewHolder as HeaderViewHolder).bind(item)
            is ListItem.Image -> (viewHolder as ImageViewHolder).bind(item)
            is ListItem.Content -> (viewHolder as ContentViewHolder).bind(item)
        }
    }
    override fun getItemCount(): Int = items.size
    override fun getItemViewType(position: Int): Int {
        return when (items[position]) {
            is ListItem.Header -> VIEW_TYPE_HEADER
            is ListItem.Image -> VIEW_TYPE_IMAGE
            is ListItem.Content -> VIEW_TYPE_CONTENT
        }
    }
    class HeaderViewHolder(private val binding: ItemFeedDetailHeaderBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: ListItem.Header) {
            binding.headerTitle.text = item.title
        }
    }
    class ImageViewHolder(private val binding: ItemFeedDetailImageBinding) : RecyclerView.ViewHolder(binding.root) {
        init {
            val width = itemView.context.resources.displayMetrics.widthPixels / 3
            itemView.layoutParams = RecyclerView.LayoutParams(width, width)
        }
        fun bind(item: ListItem.Image) {
            Glide.with(itemView.context)
                .load(item.imageUrl.toUri())
                .centerCrop()
                .into(binding.imageView)
        }
    }
    class ContentViewHolder(private val binding: ItemFeedDetailContentBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: ListItem.Content) {
            binding.authorTextView.text = item.author
            binding.contentsTextView.text = item.message
        }
    }
}
sealed class ListItem {
    data class Header(val title: String) : ListItem()
    data class Image(val text: String, val imageUrl: String) : ListItem()
    data class Content(val author: String, val message: String) : ListItem()
}