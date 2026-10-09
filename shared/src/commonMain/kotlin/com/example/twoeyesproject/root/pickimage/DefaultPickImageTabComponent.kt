package com.example.twoeyesproject.root.pickimage

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.popToFirst
import com.arkivanov.decompose.router.stack.push
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.image.component.DefaultDevicePickImageViewComponent
import com.example.twoeyesproject.image.component.DefaultMergeImageViewComponent
import com.example.twoeyesproject.root.TabComponentElement

class DefaultPickImageTabComponent(
    componentContext: ComponentContext,
    private val onMergeConfirmed: () -> Unit,
) : PickImageTabComponent, TabComponentElement, ComponentContext by componentContext {
    override val navigation = StackNavigation<PickImageTabConfig>()
    override val stack: Value<ChildStack<*, PickImageTabComponent.Child>> =
        childStack(
            source = navigation,
            serializer = PickImageTabConfig.serializer(),
            initialConfiguration = PickImageTabConfig.DevicePickImage,
            childFactory = ::child,
        )

    private fun child(config: PickImageTabConfig, componentContext: ComponentContext) : PickImageTabComponent.Child =
        when (config) {
            is PickImageTabConfig.DevicePickImage ->
                PickImageTabComponent.Child.DevicePickImageView(
                    DefaultDevicePickImageViewComponent(
                        componentContext,
                        onNextClicked = { encoded1, encoded2 ->
                            navigation.push(PickImageTabConfig.MergeImage(encoded1, encoded2))
                        }
                    )
                )
            is PickImageTabConfig.MergeImage ->
                PickImageTabComponent.Child.MergeImageView(
                    DefaultMergeImageViewComponent(
                        componentContext,
                        encoded1 = config.leftImage,
                        encoded2 = config.rightImage,
                        onBack = {
                            navigation.pop()
                        },
                        onConfirm = {
                            navigation.popToFirst()
                            onMergeConfirmed()
                        }
                    )
                )
        }
}