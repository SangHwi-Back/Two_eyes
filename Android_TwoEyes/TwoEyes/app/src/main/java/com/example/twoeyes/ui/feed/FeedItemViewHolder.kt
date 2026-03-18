package com.example.twoeyes.ui.feed

import android.view.View
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.example.twoeyes.databinding.ItemFeedBinding
import com.example.twoeyes.ui.IndexUpdateDelegate

/**
 * 피드 한 게시물을 담당하는 ViewHolder.
 *
 * iOS 로 비유하면:
 *   - FeedItemViewHolder  ≒  UITableViewCell
 *   - bindData()          ≒  func configure(with item: FeedItemModel)
 *
 * View 를 직접 찾는 대신 ViewBinding(ItemFeedBinding) 으로 접근한다.
 * → binding.imageViewPager, binding.contentsIdTextView 처럼 id 를 그대로 camelCase 로 사용.
 */
class FeedItemViewHolder(
    private val binding: ItemFeedBinding,
    private val onClickDelegate: FeedOnClickDelegate
) : RecyclerView.ViewHolder(binding.root), View.OnClickListener {

    fun bindData(item: FeedItemModel) {
        // 1. ViewPager2 에 이미지 Adapter 연결
        //    iOS 의 collectionView.dataSource = ... 에 해당
        binding.imageViewPager.adapter = ImagePagerAdapter(item.images)

        binding.pageIndicatorView.setupDots(item.images.size)

        val delegate: IndexUpdateDelegate = binding.pageIndicatorView

        binding.imageViewPager.registerOnPageChangeCallback(
            object : ViewPager2.OnPageChangeCallback() {
                override fun onPageSelected(position: Int) {
                    delegate.onUpdateIndex(position)
                }
            }
        )

        // 2. 텍스트 바인딩
        binding.contentsIdTextView.text   = item.author
        binding.contentsDescTextView.text = item.description

        // 3. 댓글 토글
        binding.tempView.visibility =
            if (item.showReply) View.VISIBLE else View.GONE

        binding.contentsShowReplyButton.setOnClickListener {
            item.showReply = !item.showReply
            bindData(item)
        }
    }

    override fun onClick(p0: View?) {
        onClickDelegate.onClickFeed(bindingAdapterPosition)
        TODO("Not yet implemented")
    }
}
