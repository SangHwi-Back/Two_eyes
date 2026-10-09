package com.example.twoeyesproject.root

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.popToFirst
import com.arkivanov.decompose.value.Value

interface TabComponentElement {
    val stack: Value<ChildStack<*, Any>>
    val navigation: StackNavigation<*>
}

fun TabComponentElement.onBackClicked() : Boolean {
    if (stack.value.backStack.isEmpty()) return false
    navigation.pop()
    return true
}

fun TabComponentElement.popToRoot() =
    navigation.popToFirst()