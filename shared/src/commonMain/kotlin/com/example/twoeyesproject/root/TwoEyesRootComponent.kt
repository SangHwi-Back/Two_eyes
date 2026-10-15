package com.example.twoeyesproject.root

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.childContext
import com.arkivanov.decompose.value.MutableValue
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.overlay.DefaultOverlayComponent
import com.example.twoeyesproject.root.feed.DefaultFeedTabComponent
import com.example.twoeyesproject.root.pickimage.DefaultPickImageTabComponent
import com.example.twoeyesproject.root.upload.DefaultUploadTabComponent

const val CONTEXT_FEED = "feed"
const val CONTEXT_PICK_IMAGE = "pick_image"
const val CONTEXT_UPLOAD = "upload"
const val CONTEXT_LOGIN = "login"
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

    override val overlayComponent = DefaultOverlayComponent(
        childContext(CONTEXT_LOGIN))

    override fun onBackClicked() : Boolean =
        if (overlayComponent.slot.value.child != null)
            overlayComponent.onDismiss()
        else
            when (_activeTab.value) {
                Config.Feed -> feedTab.onBackClicked()
                Config.PickImage -> pickImageTab.onBackClicked()
                Config.Upload -> uploadTab.onBackClicked()
            }

    override fun onTabButtonClicked(tab: Config, goBackWhenSameTab: Boolean) {
        if (goBackWhenSameTab && tab == _activeTab.value)
            onBackClicked()
        else
            _activeTab.value = tab
    }
}