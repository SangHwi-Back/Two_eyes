package com.example.twoeyesproject.image.component

import com.arkivanov.decompose.ComponentContext
import org.koin.core.component.KoinComponent

class DefaultDevicePickImageViewComponent(
    componentContext: ComponentContext,
    val onNextClicked: (String, String) -> Unit,
): DevicePickImageViewComponent, ComponentContext by componentContext, KoinComponent {
    override fun onNext(encoded1: String, encoded2: String) =
        onNextClicked(encoded1, encoded2)
}