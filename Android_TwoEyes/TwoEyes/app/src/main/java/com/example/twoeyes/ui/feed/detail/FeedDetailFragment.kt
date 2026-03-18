package com.example.twoeyes.ui.feed.detail

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.BundleCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.twoeyes.databinding.FragmentFeedDetailBinding
import com.example.twoeyes.ui.feed.FeedItemModel
import com.example.twoeyes.ui.feed.KEY_FEED_MODEL

class FeedDetailFragment : Fragment() {
    private lateinit var binding: FragmentFeedDetailBinding
    private lateinit var adapter: FeedDetailAdapter
    private lateinit var recyclerView: RecyclerView
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = FragmentFeedDetailBinding.inflate(inflater, container, false)
        recyclerView = binding.feedDetailRecyclerView
        BundleCompat.getParcelable(
            requireArguments(),
            KEY_FEED_MODEL,
            FeedItemModel::class.java
        )?.let { model ->
            var list: List<ListItem> = listOf(ListItem.Header("Feed item detail"))
            list = list + model.images.map { ListItem.Image("", it.toString()) }
            list = list + listOf(ListItem.Content(model.author, model.description))
            adapter = FeedDetailAdapter(list)
            recyclerView.layoutManager = LinearLayoutManager(requireContext())
            recyclerView.adapter = this.adapter
//            recyclerView.adapter?.notifyItemRangeInserted(0, list.size)
        }
        return binding.root
    }
}