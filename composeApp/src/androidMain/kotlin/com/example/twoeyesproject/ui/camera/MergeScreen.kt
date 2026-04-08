package com.example.twoeyesproject.ui.camera

import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.twoeyesproject.image.merge.MergeViewModel
import com.example.twoeyesproject.image.merge.MergeViewModelFactory
import kotlin.math.roundToInt
import androidx.core.net.toUri

@Composable
fun MergeScreen(
    uri1String: String,
    uri2String: String,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
) {
    // ImageSource = android.net.Uri.Builder on Android
    val source1 = remember { uri1String.toUri().buildUpon() }
    val source2 = remember { uri2String.toUri().buildUpon() }

    // Observer 구현: Z-order 변경 시 Compose state 갱신
    var zOrder by remember {
        mutableStateOf(listOf(MergeViewModel.ImageOrder.TOP, MergeViewModel.ImageOrder.BOTTOM))
    }
    val observer = remember {
        object : MergeViewModel.Observer {
            override fun didSwapedZPosition(effect: MergeViewModel.CameraMergeEffect.OnSwapZPosition) {
                zOrder = effect.order
            }
            override fun didStatusChanged(effect: MergeViewModel.CameraMergeEffect.OnStatusChanged) {
                // 현재 Compose에서 별도 상태 처리 불필요
            }
        }
    }

    val factory = remember { MergeViewModelFactory(observer, source1, source2) }
    val viewModel: MergeViewModel = viewModel(factory = factory)

    // mergeTrigger 수집 → 미리보기 이미지 갱신
    var previewBitmap by remember { mutableStateOf<ImageBitmap?>(null) }
    LaunchedEffect(viewModel) {
        viewModel.mergeTrigger.collect { bitmap ->
            previewBitmap = bitmap.asImageBitmap()
        }
    }

    // targets 수집 → 캔버스 위 이미지 표시
    val targets by viewModel.targets.collectAsStateWithLifecycle(
        initialValue = mutableListOf()
    )

    // 드래그 오프셋 (TOP, BOTTOM 각각)
    var topOffsetX by remember { mutableFloatStateOf(0f) }
    var topOffsetY by remember { mutableFloatStateOf(0f) }
    var bottomOffsetX by remember { mutableFloatStateOf(100f) }
    var bottomOffsetY by remember { mutableFloatStateOf(100f) }

    Column(modifier = Modifier.fillMaxSize()) {
        // 상단 유틸 버튼 (Refresh / Swap)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.End
        ) {
            OutlinedButton(
                onClick = { /* refresh: 초기 위치로 복원 */
                    topOffsetX = 0f; topOffsetY = 0f
                    bottomOffsetX = 100f; bottomOffsetY = 100f
                },
                modifier = Modifier.padding(end = 8.dp)
            ) { Text("↺") }

            OutlinedButton(onClick = { viewModel.swapOrder() }) { Text("⇅") }
        }

        // 캔버스 영역: 두 이미지를 드래그로 겹치기
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
        ) {
            val topTarget = targets.find { it.order == MergeViewModel.ImageOrder.TOP }
            val bottomTarget = targets.find { it.order == MergeViewModel.ImageOrder.BOTTOM }

            // Z-order 순서대로 렌더링
            zOrder.forEach { order ->
                when (order) {
                    MergeViewModel.ImageOrder.BOTTOM -> bottomTarget?.let { target ->
                        DraggableImage(
                            bitmap = target.image.asImageBitmap(),
                            offsetX = bottomOffsetX,
                            offsetY = bottomOffsetY,
                            onDrag = { dx, dy ->
                                bottomOffsetX += dx
                                bottomOffsetY += dy
                                viewModel.updatePosition(
                                    MergeViewModel.ImageOrder.BOTTOM,
                                    bottomOffsetX, bottomOffsetY
                                )
                            }
                        )
                    }
                    MergeViewModel.ImageOrder.TOP -> topTarget?.let { target ->
                        DraggableImage(
                            bitmap = target.image.asImageBitmap(),
                            offsetX = topOffsetX,
                            offsetY = topOffsetY,
                            onDrag = { dx, dy ->
                                topOffsetX += dx
                                topOffsetY += dy
                                viewModel.updatePosition(
                                    MergeViewModel.ImageOrder.TOP,
                                    topOffsetX, topOffsetY
                                )
                            }
                        )
                    }
                }
            }
        }

        HorizontalDivider()

        // 하단: 미리보기 + Confirm/Cancel
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(280.dp)
                .padding(8.dp)
        ) {
            // 병합 미리보기 (mergeTrigger 결과)
            Box(
                modifier = Modifier
                    .weight(3f)
                    .fillMaxHeight(),
                contentAlignment = Alignment.Center
            ) {
                val preview = previewBitmap
                if (preview != null) {
                    Image(
                        bitmap = preview,
                        contentDescription = "미리보기",
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Text("이미지 로딩 중...")
                }
            }

            // Confirm / Cancel
            Column(
                modifier = Modifier
                    .weight(2f)
                    .fillMaxHeight()
                    .padding(start = 8.dp),
                verticalArrangement = Arrangement.Bottom
            ) {
                Button(
                    onClick = onConfirm,
                    modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)
                ) { Text("확인") }
                OutlinedButton(
                    onClick = onCancel,
                    modifier = Modifier.fillMaxWidth()
                ) { Text("취소") }
            }
        }
    }
}

@Composable
private fun DraggableImage(
    bitmap: ImageBitmap,
    offsetX: Float,
    offsetY: Float,
    onDrag: (dx: Float, dy: Float) -> Unit,
) {
    Image(
        bitmap = bitmap,
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = Modifier
            .size(120.dp, 280.dp)
            .offset { IntOffset(offsetX.roundToInt(), offsetY.roundToInt()) }
            .pointerInput(Unit) {
                detectDragGestures { change, dragAmount ->
                    change.consume()
                    onDrag(dragAmount.x, dragAmount.y)
                }
            }
    )
}
