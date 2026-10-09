package com.example.twoeyesproject.tabcontent

import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.root.pickimage.PickImageTabComponent
import com.example.twoeyesproject.ui.camera.PickImageMergeScreen
import com.example.twoeyesproject.ui.camera.PickImageScreen

@Composable
fun PickImageTabContent(
    component: PickImageTabComponent
) {
    val stack by component.stack.subscribeAsState()
    when (val instance = stack.active.instance) {
        is PickImageTabComponent.Child.DevicePickImageView ->
            PickImageScreen(
                onNext = { uri1, uri2 ->
                    val encoded1 = Uri.encode(uri1)
                    val encoded2 = Uri.encode(uri2)
                    instance.component.onNext(encoded1, encoded2)
                },
                topAppBarDataChange = {  }
            )
        is PickImageTabComponent.Child.MergeImageView -> {
            PickImageMergeScreen(
                uri1String = instance.component.encoded1,
                uri2String = instance.component.encoded2,
                onConfirm = {
                    instance.component.onConfirmClicked()
                },
                onCancel = {
                    instance.component.onBackClicked()
                }
            )
        }

    }
}