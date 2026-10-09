package com.example.twoeyesproject.root.pickimage

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.image.component.DevicePickImageViewComponent
import com.example.twoeyesproject.image.component.MergeImageViewComponent
import kotlinx.serialization.Serializable

interface PickImageTabComponent {
    val stack: Value<ChildStack<*, Child>>

    sealed interface Child {
        data class DevicePickImageView(val component: DevicePickImageViewComponent) : Child
        data class MergeImageView(val component: MergeImageViewComponent) : Child
    }
}

@Serializable
sealed interface PickImageTabConfig {
    @Serializable
    data object DevicePickImage : PickImageTabConfig

    /// string can be converted as ImageSource.
    @Serializable
    data class MergeImage(val leftImage: String, val rightImage: String) : PickImageTabConfig
}