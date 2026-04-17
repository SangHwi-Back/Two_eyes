package com.example.twoeyesproject.ui.camera

import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.rememberTransformableState
import androidx.compose.foundation.gestures.transformable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
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
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.twoeyesproject.image.merge.MergeViewModel
import com.example.twoeyesproject.image.merge.MergeViewModelFactory
import kotlin.math.roundToInt

private val ThumbnailWidth = 120.dp
private val ThumbnailHeight = 190.dp
private val CanvasHeight = 300.dp

@Composable
fun PickImageMergeScreen(
    uri1String: String,
    uri2String: String,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
) {
    val source1 = remember { uri1String.toUri().buildUpon() }
    val source2 = remember { uri2String.toUri().buildUpon() }

    var zOrder by remember {
        mutableStateOf(listOf(MergeViewModel.ImageOrder.TOP, MergeViewModel.ImageOrder.BOTTOM))
    }
    val observer = remember {
        object : MergeViewModel.Observer {
            override fun didSwapedZPosition(effect: MergeViewModel.CameraMergeEffect.OnSwapZPosition) {
                zOrder = effect.order
            }
            override fun didStatusChanged(effect: MergeViewModel.CameraMergeEffect.OnStatusChanged) {}
        }
    }

    val factory = remember { MergeViewModelFactory(observer, source1, source2) }
    val viewModel: MergeViewModel = viewModel(factory = factory)

    var previewBitmap by remember { mutableStateOf<ImageBitmap?>(null) }
    LaunchedEffect(viewModel) {
        viewModel.mergeTrigger.collect { bitmap ->
            previewBitmap = bitmap.asImageBitmap()
        }
    }

    val targets by viewModel.targets.collectAsStateWithLifecycle(initialValue = mutableListOf())

    var leadingOffsetX by remember { mutableFloatStateOf(0f) }
    var leadingOffsetY by remember { mutableFloatStateOf(0f) }
    var leadingScale by remember { mutableFloatStateOf(1f) }

    var trailingOffsetX by remember { mutableFloatStateOf(0f) }
    var trailingOffsetY by remember { mutableFloatStateOf(0f) }
    var trailingInitialized by remember { mutableStateOf(false) }
    var trailingScale by remember { mutableFloatStateOf(1f) }

    Column(modifier = Modifier.fillMaxSize()) {

        // 캔버스: 두 이미지를 드래그·핀치로 겹치는 영역
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(CanvasHeight)
        ) {
            val density = LocalDensity.current

            // trailing 초기 위치: 오른쪽 끝 (iOS: proxy.size.width - thumbnailSize.width)
            LaunchedEffect(maxWidth) {
                if (!trailingInitialized) {
                    trailingOffsetX = with(density) { (maxWidth - ThumbnailWidth).toPx() }
                    trailingInitialized = true
                }
            }

            val leadingTarget = targets.find { it.order == MergeViewModel.ImageOrder.BOTTOM }
            val trailingTarget = targets.find { it.order == MergeViewModel.ImageOrder.TOP }

            zOrder.forEach { order ->
                when (order) {
                    MergeViewModel.ImageOrder.BOTTOM -> leadingTarget?.let {
                        TransformableImage(
                            bitmap = it.image.asImageBitmap(),
                            offsetX = leadingOffsetX,
                            offsetY = leadingOffsetY,
                            scale = leadingScale,
                            onDrag = { dx, dy ->
                                leadingOffsetX += dx
                                leadingOffsetY += dy
                                viewModel.updatePosition(
                                    MergeViewModel.ImageOrder.BOTTOM,
                                    leadingOffsetX, leadingOffsetY
                                )
                            },
                            onScale = { factor -> leadingScale *= factor }
                        )
                    }
                    MergeViewModel.ImageOrder.TOP -> trailingTarget?.let {
                        TransformableImage(
                            bitmap = it.image.asImageBitmap(),
                            offsetX = trailingOffsetX,
                            offsetY = trailingOffsetY,
                            scale = trailingScale,
                            onDrag = { dx, dy ->
                                trailingOffsetX += dx
                                trailingOffsetY += dy
                                viewModel.updatePosition(
                                    MergeViewModel.ImageOrder.TOP,
                                    trailingOffsetX, trailingOffsetY
                                )
                            },
                            onScale = { factor -> trailingScale *= factor }
                        )
                    }
                }
            }

            // Swap 버튼: 캔버스 우상단 오버레이
            IconButton(
                onClick = { viewModel.swapOrder() },
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(4.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.SwapHoriz,
                    contentDescription = "순서 교환",
                    tint = MaterialTheme.colorScheme.onSurface
                )
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // 합성 미리보기 (iOS: ZStack with RoundedRectangle border + aspect ratio 1.6 ≈ 16:10)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .aspectRatio(16f / 10f)
                .border(
                    width = 1.dp,
                    color = MaterialTheme.colorScheme.outline,
                    shape = RoundedCornerShape(8.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            val preview = previewBitmap
            if (preview != null) {
                Image(
                    bitmap = preview,
                    contentDescription = "합성 미리보기",
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(8.dp)
                )
            } else {
                CircularProgressIndicator()
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // 하단 버튼: 취소 + 확인
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            OutlinedButton(
                onClick = onCancel,
                modifier = Modifier.weight(1f)
            ) { Text("취소") }
            Button(
                onClick = onConfirm,
                modifier = Modifier.weight(1f)
            ) { Text("확인") }
        }
    }
}

@Composable
private fun TransformableImage(
    bitmap: ImageBitmap,
    offsetX: Float,
    offsetY: Float,
    scale: Float,
    onDrag: (dx: Float, dy: Float) -> Unit,
    onScale: (factor: Float) -> Unit,
) {
    // transformable 은 단일 손가락 pan + 핀치 줌을 모두 처리
    val transformableState = rememberTransformableState { zoomChange, panChange, _ ->
        onDrag(panChange.x, panChange.y)
        onScale(zoomChange)
    }
    Image(
        bitmap = bitmap,
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = Modifier
            .size(ThumbnailWidth, ThumbnailHeight)
            .offset { IntOffset(offsetX.roundToInt(), offsetY.roundToInt()) }
            .scale(scale)
            .transformable(state = transformableState)
    )
}
