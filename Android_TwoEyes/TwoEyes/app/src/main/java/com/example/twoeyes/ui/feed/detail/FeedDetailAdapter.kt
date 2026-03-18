package com.example.twoeyes.ui.feed.detail

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
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
            VIEW_TYPE_HEADER -> HeaderViewHolder(
                inflater.inflate(R.layout.item_feed_detail_header, parent, false),
                ItemFeedDetailHeaderBinding.inflate(inflater))
            VIEW_TYPE_IMAGE -> ImageViewHolder(
                inflater.inflate(R.layout.item_feed_detail_image, parent, false),
                ItemFeedDetailImageBinding.inflate(inflater))
            VIEW_TYPE_CONTENT -> ContentViewHolder(
                inflater.inflate(R.layout.item_feed_detail_content, parent, false),
                ItemFeedDetailContentBinding.inflate(inflater))
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
    class HeaderViewHolder(view: View, binding: ItemFeedDetailHeaderBinding) : RecyclerView.ViewHolder(view) {
        fun bind(item: ListItem.Header) {

        }
    }
    class ImageViewHolder(view: View, binding: ItemFeedDetailImageBinding) : RecyclerView.ViewHolder(view) {
        fun bind(item: ListItem.Image) {

        }
    }
    class ContentViewHolder(view: View, binding: ItemFeedDetailContentBinding) : RecyclerView.ViewHolder(view) {
        fun bind(item: ListItem.Content) {

        }
    }
}
sealed class ListItem {
    data class Header(val title: String) : ListItem()
    data class Image(val text: String, val imageUrl: String) : ListItem()
    data class Content(val message: String) : ListItem()
}