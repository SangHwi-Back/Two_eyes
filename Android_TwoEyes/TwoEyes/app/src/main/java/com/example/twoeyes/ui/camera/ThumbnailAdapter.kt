package com.example.twoeyes.ui.camera

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.R

class ThumbnailAdapter(
    private val onItemClick: (Any) -> Unit
) : RecyclerView.Adapter<ThumbnailAdapter.ViewHolder>() {
    private var items: List<Any> = emptyList()
    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val imageView: ImageView = view.findViewById(R.id.thumbnail_image_view)
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.thumbnail_image_view, parent, false)
        return ViewHolder(view)
    }
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        Glide.with(holder.itemView).load(item).into(holder.imageView)
        holder.itemView.setOnClickListener { onItemClick(item) }
    }
    override fun getItemCount(): Int = items.size
    fun updateList(newItems: List<Any>) {
        items = newItems
        notifyDataSetChanged()
    }
}