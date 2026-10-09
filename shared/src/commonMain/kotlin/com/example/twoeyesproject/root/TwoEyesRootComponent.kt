package com.example.twoeyesproject.root

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.childContext
import com.arkivanov.decompose.value.MutableValue
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.root.feed.DefaultFeedTabComponent
import com.example.twoeyesproject.root.pickimage.DefaultPickImageTabComponent
import com.example.twoeyesproject.root.upload.DefaultUploadTabComponent

const val CONTEXT_FEED = "feed"
const val CONTEXT_PICK_IMAGE = "pick_image"
const val CONTEXT_UPLOAD = "upload"
class TwoEyesRootComponent(
    componentContext: ComponentContext,
) : RootComponent, ComponentContext by componentContext {
    override val feedTab = DefaultFeedTabComponent(
        childContext(CONTEXT_FEED))
    override val pickImageTab = DefaultPickImageTabComponent(
        childContext(CONTEXT_PICK_IMAGE),
        onMergeConfirmed = {
            feedTab.popToRoot()
            _activeTab.value = Config.Feed
        }
    )
    override val uploadTab = DefaultUploadTabComponent(
        childContext(CONTEXT_UPLOAD))

    private val _activeTab = MutableValue<Config>(Config.Feed)
    override val active: Value<Config> = _activeTab

    /**
     * Android 전용. iOS 에서는 호출되지 않음.
     */
    override fun onBackClicked() : Boolean =
        when (_activeTab.value) {
            Config.Feed -> feedTab.onBackClicked()
            Config.PickImage -> pickImageTab.onBackClicked()
            Config.Upload -> uploadTab.onBackClicked()
        }

    override fun onTabButtonClicked(tab: Config) {
        _activeTab.value = tab
    }
}