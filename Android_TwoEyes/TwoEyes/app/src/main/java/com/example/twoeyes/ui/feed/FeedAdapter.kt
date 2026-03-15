package com.example.twoeyes.ui.feed

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.example.twoeyes.databinding.ItemFeedBinding

class FeedAdapter(
    private val layoutInflater: LayoutInflater
) : RecyclerView.Adapter<FeedItemViewHolder>() {

    private var listData = mutableListOf<FeedItemModel>()
    fun setListData(newData: FeedItemModel) {
        listData.add(newData)
        notifyItemInserted(listData.size - 1)
    }
    fun setListData(newList: List<FeedItemModel>) {
        val prevListSize = listData.size
        listData = newList.toMutableList()
        notifyItemRangeChanged(0, listData.size)

        if (prevListSize > listData.size) {
            notifyItemRangeRemoved(listData.size, prevListSize - listData.size)
        }
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): FeedItemViewHolder {
        val binding = ItemFeedBinding.inflate(layoutInflater, parent, false)
        return FeedItemViewHolder(binding)
    }

    override fun onBindViewHolder(
        holder: FeedItemViewHolder,
        position: Int
    ) {
        holder.bindData(listData[position])
    }

    override fun getItemCount(): Int = listData.size
}