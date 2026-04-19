package com.example.twoeyesproject.ui.camera

import android.graphics.Bitmap
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
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageMerger
import com.example.twoeyesproject.image.ImageMergerModel
import com.example.twoeyesproject.image.merge.PickImageMergeViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlin.math.roundToInt

private val ThumbnailWidth  = 120.dp
private val ThumbnailHeight = 190.dp
private val CanvasHeight    = 300.dp

@Composable
fun PickImageMergeScreen(
    uri1String: String,
    uri2String: String,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
) {
    val source1 = remember { uri1String.toUri().buildUpon() }
    val source2 = remember { uri2String.toUri().buildUpon() }

    // ── ViewModel (위치·z순서만 관리) ─────────────────────────────────────────
    val viewModel: PickImageMergeViewModel = viewModel()
    val zOrder by viewModel.zOrder.collectAsStateWithLifecycle()

    // ── 이미지 디코딩 (뷰 레이어 담당) ───────────────────────────────────────
    var leadingBitmap:  Bitmap? by remember { mutableStateOf(null) }
    var trailingBitmap: Bitmap? by remember { mutableStateOf(null) }
    LaunchedEffect(Unit) {
        val decoder = ImageDecoder()
        leadingBitmap  = withContext(Dispatchers.IO) { decoder.decode(source1) }
        trailingBitmap = withContext(Dispatchers.IO) { decoder.decode(source2) }
    }

    // ── 제스처 상태 ───────────────────────────────────────────────────────────
    var leadingOffsetX  by remember { mutableFloatStateOf(0f) }
    var leadingOffsetY  by remember { mutableFloatStateOf(0f) }
    var leadingScale    by remember { mutableFloatStateOf(1f) }

    var trailingOffsetX by remember { mutableFloatStateOf(0f) }
    var trailingOffsetY by remember { mutableFloatStateOf(0f) }
    var trailingScale   by remember { mutableFloatStateOf(1f) }
    var initialized     by remember { mutableStateOf(false) }

    // ── 합성 미리보기 ─────────────────────────────────────────────────────────
    var previewBitmap by remember { mutableStateOf<ImageBitmap?>(null) }

    Column(modifier = Modifier.fillMaxSize()) {

        // ── 제스처 캔버스 ─────────────────────────────────────────────────────
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(CanvasHeight)
        ) {
            val density      = LocalDensity.current
            val canvasWidthPx  = with(density) { maxWidth.roundToPx() }
            val canvasHeightPx = with(density) { CanvasHeight.roundToPx() }
            val thumbWidthPx   = with(density) { ThumbnailWidth.toPx() }
            val thumbHeightPx  = with(density) { ThumbnailHeight.toPx() }

            // 초기 위치: iOS 와 동일하게 캔버스 좌우 절반 중앙
            LaunchedEffect(maxWidth) {
                if (!initialized) {
                    val cw = with(density) { maxWidth.toPx() }
                    val tw = with(density) { ThumbnailWidth.toPx() }
                    leadingOffsetX  = cw / 4f - tw / 2f
                    trailingOffsetX = 3f * cw / 4f - tw / 2f
                    initialized = true
                    viewModel.updateLeading( leadingOffsetX,  leadingOffsetY,  leadingScale)
                    viewModel.updateTrailing(trailingOffsetX, trailingOffsetY, trailingScale)
                }
            }

            // 위치·비트맵이 바뀔 때마다 합성 이미지 재생성
            LaunchedEffect(
                leadingOffsetX, leadingOffsetY, leadingScale,
                trailingOffsetX, trailingOffsetY, trailingScale,
                zOrder, leadingBitmap, trailingBitmap
            ) {
                val lBitmap = leadingBitmap  ?: return@LaunchedEffect
                val tBitmap = trailingBitmap ?: return@LaunchedEffect
                previewBitmap = withContext(Dispatchers.Default) {
                    renderMerged(
                        canvasWidthPx  = canvasWidthPx,
                        canvasHeightPx = canvasHeightPx,
                        leadingBitmap  = lBitmap,
                        leadingOffsetX = leadingOffsetX,
                        leadingOffsetY = leadingOffsetY,
                        leadingScale   = leadingScale,
                        trailingBitmap = tBitmap,
                        trailingOffsetX = trailingOffsetX,
                        trailingOffsetY = trailingOffsetY,
                        trailingScale   = trailingScale,
                        zOrder          = zOrder,
                        thumbWidthPx    = thumbWidthPx,
                        thumbHeightPx   = thumbHeightPx
                    ).asImageBitmap()
                }
            }

            // z순서대로 이미지 렌더
            zOrder.forEach { order ->
                when (order) {
                    PickImageMergeViewModel.ImageOrder.BOTTOM -> {
                        leadingBitmap?.asImageBitmap()?.let { bmp ->
                            TransformableImage(
                                bitmap    = bmp,
                                offsetX   = leadingOffsetX,
                                offsetY   = leadingOffsetY,
                                scale     = leadingScale,
                                onDrag    = { dx, dy ->
                                    leadingOffsetX += dx; leadingOffsetY += dy
                                    viewModel.updateLeading(leadingOffsetX, leadingOffsetY, leadingScale)
                                },
                                onScale   = { f ->
                                    leadingScale *= f
                                    viewModel.updateLeading(leadingOffsetX, leadingOffsetY, leadingScale)
                                }
                            )
                        }
                    }
                    PickImageMergeViewModel.ImageOrder.TOP -> {
                        trailingBitmap?.asImageBitmap()?.let { bmp ->
                            TransformableImage(
                                bitmap    = bmp,
                                offsetX   = trailingOffsetX,
                                offsetY   = trailingOffsetY,
                                scale     = trailingScale,
                                onDrag    = { dx, dy ->
                                    trailingOffsetX += dx; trailingOffsetY += dy
                                    viewModel.updateTrailing(trailingOffsetX, trailingOffsetY, trailingScale)
                                },
                                onScale   = { f ->
                                    trailingScale *= f
                                    viewModel.updateTrailing(trailingOffsetX, trailingOffsetY, trailingScale)
                                }
                            )
                        }
                    }
                }
            }

            // Swap 버튼
            IconButton(
                onClick   = { viewModel.swapOrder() },
                modifier  = Modifier
                    .align(Alignment.TopEnd)
                    .padding(4.dp)
            ) {
                Icon(
                    imageVector  = Icons.Default.SwapHoriz,
                    contentDescription = "순서 교환",
                    tint         = MaterialTheme.colorScheme.onSurface
                )
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // ── 합성 미리보기 ─────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .aspectRatio(16f / 10f)
                .border(
                    width  = 1.dp,
                    color  = MaterialTheme.colorScheme.outline,
                    shape  = RoundedCornerShape(8.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            val preview = previewBitmap
            if (preview != null) {
                Image(
                    bitmap        = preview,
                    contentDescription = "합성 미리보기",
                    contentScale  = ContentScale.Fit,
                    modifier      = Modifier
                        .fillMaxSize()
                        .padding(8.dp)
                )
            } else {
                CircularProgressIndicator()
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        // ── 하단 버튼 ─────────────────────────────────────────────────────────
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            OutlinedButton(
                onClick  = onCancel,
                modifier = Modifier.weight(1f)
            ) { Text("취소") }
            Button(
                onClick  = onConfirm,
                modifier = Modifier.weight(1f)
            ) { Text("확인") }
        }
    }
}

// ── 합성 렌더링 ───────────────────────────────────────────────────────────────
private fun renderMerged(
    canvasWidthPx:  Int,
    canvasHeightPx: Int,
    leadingBitmap:  Bitmap,
    leadingOffsetX: Float,
    leadingOffsetY: Float,
    leadingScale:   Float,
    trailingBitmap: Bitmap,
    trailingOffsetX: Float,
    trailingOffsetY: Float,
    trailingScale:   Float,
    zOrder:          List<PickImageMergeViewModel.ImageOrder>,
    thumbWidthPx:    Float,
    thumbHeightPx:   Float,
): Bitmap {
    fun makeFrame(ox: Float, oy: Float, s: Float) = ImageFrame(
        left   = ox,
        top    = oy,
        right  = ox + thumbWidthPx * s,
        bottom = oy + thumbHeightPx * s
    )

    val leadingFrame  = makeFrame(leadingOffsetX,  leadingOffsetY,  leadingScale)
    val trailingFrame = makeFrame(trailingOffsetX, trailingOffsetY, trailingScale)

    val isLeadingBottom = zOrder.firstOrNull() == PickImageMergeViewModel.ImageOrder.BOTTOM
    val model = ImageMergerModel(
        canvasWidth  = canvasWidthPx,
        canvasHeight = canvasHeightPx,
        bottomImage  = ImageMergerModel.ImageInfo(
            image = if (isLeadingBottom) leadingBitmap  else trailingBitmap,
            frame = if (isLeadingBottom) leadingFrame   else trailingFrame
        ),
        topImage     = ImageMergerModel.ImageInfo(
            image = if (isLeadingBottom) trailingBitmap else leadingBitmap,
            frame = if (isLeadingBottom) trailingFrame  else leadingFrame
        ),
        blendAlpha   = 0.5f
    )

    return ImageMerger().merge(model)
}

// ── TransformableImage ────────────────────────────────────────────────────────
@Composable
private fun TransformableImage(
    bitmap:   ImageBitmap,
    offsetX:  Float,
    offsetY:  Float,
    scale:    Float,
    onDrag:   (dx: Float, dy: Float) -> Unit,
    onScale:  (factor: Float) -> Unit,
) {
    val transformableState = rememberTransformableState { zoomChange, panChange, _ ->
        onDrag(panChange.x, panChange.y)
        onScale(zoomChange)
    }
    Image(
        bitmap        = bitmap,
        contentDescription = null,
        contentScale  = ContentScale.Crop,
        modifier      = Modifier
            .size(ThumbnailWidth, ThumbnailHeight)
            .offset { IntOffset(offsetX.roundToInt(), offsetY.roundToInt()) }
            .scale(scale)
            .transformable(state = transformableState)
    )
}
