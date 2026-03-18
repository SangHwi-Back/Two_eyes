package com.example.twoeyes.ui.feed

import android.net.Uri
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.twoeyes.R
import com.example.twoeyes.databinding.FragmentFeedBinding

interface FeedFragmentNavigationDelegate {
    fun onFeedClicked(model: FeedItemModel)
}
class FeedFragment : Fragment(), FeedFragmentNavigationDelegate {
    private lateinit var binding: FragmentFeedBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentFeedBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val adapter = FeedAdapter(layoutInflater)

        binding.feedRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        binding.feedRecyclerView.adapter = adapter
        binding.feedRecyclerView

        adapter.setListData(createMockData())
    }

    override fun onFeedClicked(model: FeedItemModel) {
        findNavController().navigate(
            R.id.action_feed_fragment_to_feedDetailFragment,
            bundleOf("model" to model))
    }

    // 목 데이터 - 화면 확인 후 삭제 예정
    // picsum.photos: 무료 랜덤 이미지 제공 서비스 (seed 값으로 항상 같은 이미지 반환)
    private fun createMockData(): List<FeedItemModel> = listOf(
        FeedItemModel(
            images = listOf(
                Uri.parse("https://picsum.photos/seed/a1/600/600"),
                Uri.parse("https://picsum.photos/seed/a2/600/600"),
                Uri.parse("https://picsum.photos/seed/a3/600/600"),
            ),
            likes = 42,
            author = "mock_user_1",
            description = "이미지 3장짜리 게시물입니다. 좌우로 스와이프해보세요.",
            showReply = false,
        ),
        FeedItemModel(
            images = listOf(
                Uri.parse("https://picsum.photos/seed/b1/600/600"),
            ),
            likes = 100,
            author = "mock_user_2",
            description = "이미지 1장짜리 게시물입니다.",
            showReply = false,
        ),
        FeedItemModel(
            images = listOf(
                Uri.parse("https://picsum.photos/seed/c1/600/600"),
                Uri.parse("https://picsum.photos/seed/c2/600/600"),
            ),
            likes = 7,
            author = "mock_user_3",
            description = "이미지 2장짜리 게시물입니다.",
            showReply = false,
        ),
    )
}