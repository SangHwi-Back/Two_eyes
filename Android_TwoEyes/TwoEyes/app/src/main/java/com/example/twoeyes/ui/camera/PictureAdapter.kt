package com.example.twoeyes.ui.camera

import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.viewpager2.adapter.FragmentStateAdapter

// ViewPager2 Adapter
class PictureAdapter(
    activity: AppCompatActivity,
    private val imageList: List<Any>
) : FragmentStateAdapter(activity) {
    override fun getItemCount(): Int = imageList.size
    override fun createFragment(position: Int): Fragment {
        return PictureFragment.newInstance(imageList[position])
    }
}