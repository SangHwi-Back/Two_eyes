package com.example.twoeyesproject.root.upload

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.*
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.root.TabComponentElement
import com.example.twoeyesproject.upload.component.DefaultUploadViewComponent
import com.example.twoeyesproject.upload.component.DefaultUploadableListViewComponent

class DefaultUploadTabComponent(
    componentContext: ComponentContext
) : UploadTabComponent, TabComponentElement, ComponentContext by componentContext {
    override val navigation = StackNavigation<UploadTabConfig>()
    override val stack: Value<ChildStack<*, UploadTabComponent.Child>> =
        childStack(
            source = navigation,
            serializer = UploadTabConfig.serializer(),
            initialConfiguration = UploadTabConfig.UploadableList,
            childFactory = ::child,
        )

    private fun child(config: UploadTabConfig, componentContext: ComponentContext) : UploadTabComponent.Child =
        when (config) {
            is UploadTabConfig.UploadableList ->
                UploadTabComponent.Child.UploadableListView(
                    DefaultUploadableListViewComponent(
                        componentContext,
                        onNext = {
                            val target = UploadTabConfig.UploadView(it)
                            if (stack.value.items.none { it.configuration == target }) {
                                navigation.push(target)
                            }
                        }
                    )
                )
            is UploadTabConfig.UploadView ->
                UploadTabComponent.Child.UploadView(
                    DefaultUploadViewComponent(
                        componentContext,
                        onBack = {
                            navigation.pop()
                        }
                    )
                )
        }
}