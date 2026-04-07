package com.example.twoeyesproject.platformspecific

expect interface PlatformParcelable

@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.BINARY)
expect annotation class Parcelize()