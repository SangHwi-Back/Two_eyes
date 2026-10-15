package com.example.twoeyesproject.root

import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.component.LoginComponent
import com.example.twoeyesproject.root.feed.FeedTabComponent
import com.example.twoeyesproject.root.pickimage.PickImageTabComponent
import com.example.twoeyesproject.root.upload.UploadTabComponent
import kotlinx.serialization.Serializable

interface RootComponent {
    val active : Value<Config>
    val overlayScreen : Value<Overlay>
    val feedTab: FeedTabComponent
    val pickImageTab: PickImageTabComponent
    val uploadTab: UploadTabComponent
    fun onBackClicked() : Boolean
    fun onTabButtonClicked(tab: Config, goBackWhenSameTab: Boolean)
    fun showOverlay(overlay: Overlay)
    fun showLogin()
    sealed interface Child {
        data class Feed(val component: FeedTabComponent) : Child
        data class PickImage(val component: PickImageTabComponent) : Child
        data class Upload(val component: UploadTabComponent) : Child
    }
    sealed interface Overlay {
        data object None : Overlay
        data class Login(val component: LoginComponent) : Overlay
    }
}

@Serializable
sealed interface Config {
    @Serializable
    data object Feed : Config

    @Serializable
    data object PickImage : Config

    @Serializable
    data object Upload : Config
}