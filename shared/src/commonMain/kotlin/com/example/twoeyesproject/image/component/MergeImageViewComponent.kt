package com.example.twoeyesproject.image.component

interface MergeImageViewComponent {
    val encoded1: String
    val encoded2: String
    fun onBackClicked()
    fun onConfirmClicked()
}