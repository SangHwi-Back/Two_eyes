package com.example.twoeyesproject.ui.feed

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.unit.sp
import com.example.twoeyesproject.feeddetail.FeedDetailComponent

@Composable
fun FeedDetailContent(component: FeedDetailComponent) {
    val item by component.feedItem.collectAsState()
    Column {
        Text("Testing! ${item?.author ?: ""}", fontSize = 120.sp)
    }
}