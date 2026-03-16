package com.example.twoeyes.ui.feed

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.twoeyes.databinding.ItemFeedImageBinding

/**
 * ViewPager2 에 들어가는 이미지 목록 Adapter.
 *
 * iOS 로 비유하면:
 *   - ImagePagerAdapter  ≒  UICollectionViewDataSource (내부 수평 스크롤용)
 *   - ImageViewHolder    ≒  UICollectionViewCell
 *
 * FeedItemViewHolder 안의 ViewPager2 에 연결해서 사용한다.
 *   feedImageViewPager.adapter = ImagePagerAdapter(images)
 */
class ImagePagerAdapter(
    private val images: List<Uri>
) : RecyclerView.Adapter<ImagePagerAdapter.ImageViewHolder>() {

    // iOS 의 cellForItemAt 에 해당
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ImageViewHolder {
        val binding = ItemFeedImageBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ImageViewHolder(binding)
    }

    // iOS 의 cellForItemAt 에서 cell.configure(with:) 에 해당
    override fun onBindViewHolder(holder: ImageViewHolder, position: Int) {
        holder.bind(images[position])
    }

    override fun getItemCount(): Int = images.size

    // ViewHolder: 셀 한 칸을 담당. binding 으로 뷰에 접근한다.
    class ImageViewHolder(
        private val binding: ItemFeedImageBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        fun bind(uri: Uri) {
            // Glide 로 Uri → ImageView 로드
            // Glide.with(context) 에서 context 는 itemView.context 로 얻는다.
            Glide.with(itemView.context)
                .load(uri)
                .centerCrop()   // 1:1 비율 유지하며 채움
                .into(binding.feedImageView)
        }
    }
}
