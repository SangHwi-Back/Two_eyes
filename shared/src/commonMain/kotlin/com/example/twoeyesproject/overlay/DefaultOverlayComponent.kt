package com.example.twoeyesproject.overlay

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.slot.ChildSlot
import com.arkivanov.decompose.router.slot.SlotNavigation
import com.arkivanov.decompose.router.slot.activate
import com.arkivanov.decompose.router.slot.childSlot
import com.arkivanov.decompose.router.slot.dismiss
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.overlay.component.DefaultLoginComponent
import com.example.twoeyesproject.root.OverlayConfig

class DefaultOverlayComponent(
    componentContext: ComponentContext
) : OverlayComponent, ComponentContext by componentContext {
    private val overlayNavigation = SlotNavigation<OverlayConfig>()

    override val slot: Value<ChildSlot<*, OverlayComponent.OverlaySlot>> =
        childSlot(
            source = overlayNavigation,
            serializer = OverlayConfig.serializer(),
            handleBackButton = true,
        ) { config, childContextComponent ->
            when (config) {
                OverlayConfig.Login -> OverlayComponent.OverlaySlot.Login(DefaultLoginComponent(
                    componentContext = childContextComponent,
                    onConfirmed = {
                        onDismiss()
                    },
                    onCanceled = {
                        onDismiss()
                    }
                ))
            }
        }

    override fun onDismiss() : Boolean {
        var dismissed = false
        overlayNavigation.dismiss { dismissedWithNoError ->
            dismissed = dismissedWithNoError
        }
        return dismissed
    }

    override fun showLogin() {
        overlayNavigation.activate(OverlayConfig.Login)
    }
}