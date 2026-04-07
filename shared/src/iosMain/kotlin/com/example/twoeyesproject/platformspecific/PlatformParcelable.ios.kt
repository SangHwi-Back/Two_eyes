package com.example.twoeyesproject.platformspecific

actual interface PlatformParcelable

@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.BINARY)
actual annotation class Parcelize actual constructor()