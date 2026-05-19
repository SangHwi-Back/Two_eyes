package com.example.twoeyesproject.ui.camera

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.RadialGradient
import android.graphics.Shader
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.graphics.ColorMatrixColorFilter
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.graphics.asAndroidColorFilter
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.twoeyesproject.AppConstants
import com.example.twoeyesproject.dependency.AppDatabase
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.image.ImageDecoder
import com.example.twoeyesproject.image.ImageFrame
import com.example.twoeyesproject.image.ImageMerger
import com.example.twoeyesproject.image.ImageMergerModel
import com.example.twoeyesproject.image.merge.PickImageMergeViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.koin.compose.koinInject
import kotlin.math.roundToInt

private val CanvasHeight = 300.dp

// ── Filter enum 표시 이름 ────────────────────────────────────────────────────
private val PickImageMergeViewModel.ImageState.Filter.label: String
    get() = when (this) {
        PickImageMergeViewModel.ImageState.Filter.INVERTED   -> "반전"
        PickImageMergeViewModel.ImageState.Filter.MONOCHROME -> "흑백"
        PickImageMergeViewModel.ImageState.Filter.CONTRAST   -> "대비"
        PickImageMergeViewModel.ImageState.Filter.SATURATION -> "채도"
        PickImageMergeViewModel.ImageState.Filter.VIGNETTE   -> "비네트"
    }

@Composable
fun PickImageMergeScreen(
    uri1String: String,
    uri2String: String,
    onConfirm: () -> Unit,
    onCancel: () -> Unit,
) {
    val db: AppDatabase = koinInject()
    val source1 = remember { uri1String.toUri().buildUpon() }
    val source2 = remember { uri2String.toUri().buildUpon() }

    // ── ViewModel ───────────────────────────────────────────────────────────
    val viewModel: PickImageMergeViewModel = viewModel()
    val zOrder   by viewModel.zOrder.collectAsStateWithLifecycle()
    val leading  by viewModel.leading.collectAsStateWithLifecycle()
    val trailing by viewModel.trailing.collectAsStateWithLifecycle()

    // ── 이미지 디코딩 ────────────────────────────────────────────────────────
    var leadingBitmap:  Bitmap? by remember { mutableStateOf(null) }
    var trailingBitmap: Bitmap? by remember { mutableStateOf(null) }
    LaunchedEffect(Unit) {
        val decoder = ImageDecoder()
        leadingBitmap  = withContext(Dispatchers.IO) { decoder.decode(source1) }
        trailingBitmap = withContext(Dispatchers.IO) { decoder.decode(source2) }
    }

    // ── 제스처 상태 ──────────────────────────────────────────────────────────
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
            val density        = LocalDensity.current
            val canvasWidthPx  = with(density) { maxWidth.roundToPx() }
            val canvasHeightPx = with(density) { CanvasHeight.roundToPx() }

            // 초기 위치: 캔버스 좌우 절반 중앙
            LaunchedEffect(maxWidth) {
                if (!initialized) {
                    val cw = with(density) { maxWidth.toPx() }
                    val tw = with(density) { AppConstants.THUMBNAIL_SIZE_WIDTH.dp.toPx() }
                    leadingOffsetX  = cw / 4f - tw / 2f
                    trailingOffsetX = 3f * cw / 4f - tw / 2f
                    initialized = true
                    viewModel.updateLeading( leadingOffsetX,  leadingOffsetY,  leadingScale)
                    viewModel.updateTrailing(trailingOffsetX, trailingOffsetY, trailingScale)
                }
            }

            // 위치·필터·비트맵이 바뀔 때마다 합성 이미지 재생성
            LaunchedEffect(
                leadingOffsetX, leadingOffsetY, leadingScale,
                trailingOffsetX, trailingOffsetY, trailingScale,
                zOrder, leadingBitmap, trailingBitmap,
                leading.filter, trailing.filter
            ) {
                val lBitmap = leadingBitmap  ?: return@LaunchedEffect
                val tBitmap = trailingBitmap ?: return@LaunchedEffect
                previewBitmap = withContext(Dispatchers.Default) {
                    // ViewModel StateFlow 를 직접 읽어야 함: collected state(leading/trailing)는
                    // LaunchedEffect가 실행되는 시점에 한 프레임 지연이 있어 이전 좌표를 반환할 수 있음.
                    // leading.filter는 키로만 사용해 필터 변경 시 재실행을 트리거.
                    renderMerged(
                        canvasWidthPx  = canvasWidthPx,
                        canvasHeightPx = canvasHeightPx,
                        leadingBitmap  = lBitmap,
                        leadingState   = viewModel.leading.value,
                        trailingBitmap = tBitmap,
                        trailingState  = viewModel.trailing.value,
                        zOrder         = zOrder,
                    ).asImageBitmap()
                }
            }

            // z순서대로 이미지 렌더
            zOrder.forEach { order ->
                when (order) {
                    PickImageMergeViewModel.ImageOrder.BOTTOM -> {
                        leadingBitmap?.asImageBitmap()?.let { bmp ->
                            TransformableImage(
                                bitmap  = bmp,
                                offsetX = leadingOffsetX,
                                offsetY = leadingOffsetY,
                                scale   = leadingScale,
                                onDrag  = { dx, dy ->
                                    leadingOffsetX += dx; leadingOffsetY += dy
                                    viewModel.updateLeading(leadingOffsetX, leadingOffsetY, leadingScale)
                                },
                                onScale = { f ->
                                    leadingScale *= f
                                    viewModel.updateLeading(leadingOffsetX, leadingOffsetY, leadingScale)
                                }
                            )
                        }
                    }
                    PickImageMergeViewModel.ImageOrder.TOP -> {
                        trailingBitmap?.asImageBitmap()?.let { bmp ->
                            TransformableImage(
                                bitmap  = bmp,
                                offsetX = trailingOffsetX,
                                offsetY = trailingOffsetY,
                                scale   = trailingScale,
                                onDrag  = { dx, dy ->
                                    trailingOffsetX += dx; trailingOffsetY += dy
                                    viewModel.updateTrailing(trailingOffsetX, trailingOffsetY, trailingScale)
                                },
                                onScale = { f ->
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
                onClick  = { viewModel.swapOrder() },
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(4.dp)
            ) {
                Icon(
                    imageVector        = Icons.Default.SwapHoriz,
                    contentDescription = "순서 교환",
                    tint               = Color(AppColors.Surface2)
                )
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // ── 필터 선택 ────────────────────────────────────────────────────────
        FilterSelector(
            leadingFilter  = leading.filter,
            trailingFilter = trailing.filter,
            onLeadingFilterChange  = { viewModel.setLeadingFilter(it) },
            onTrailingFilterChange = { viewModel.setTrailingFilter(it) },
        )

        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

        // ── 합성 미리보기 ─────────────────────────────────────────────────────
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .aspectRatio(16f / 10f)
                .border(
                    width = 1.dp,
                    color = Color(AppColors.Surface),
                    shape = RoundedCornerShape(8.dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            val preview = previewBitmap
            if (preview != null) {
                Image(
                    bitmap             = preview,
                    contentDescription = "합성 미리보기",
                    contentScale       = ContentScale.Fit,
                    modifier           = Modifier
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
                onClick = {
                    if (previewBitmap != null)
                        viewModel.saveMergedImage(
                            dao             = db.getMergeResultDao(),
                            mergedImage     = (previewBitmap as ImageBitmap).asAndroidBitmap(),
                            leadingImageId  = source1.toString(),
                            trailingImageId = source2.toString(),
                            name            = "Testing"
                        )
                    onConfirm()
                },
                modifier = Modifier.weight(1f)
            ) { Text("확인") }
        }
    }
}

// ── 필터 선택 UI ──────────────────────────────────────────────────────────────
@Composable
private fun FilterSelector(
    leadingFilter:          PickImageMergeViewModel.ImageState.Filter?,
    trailingFilter:         PickImageMergeViewModel.ImageState.Filter?,
    onLeadingFilterChange:  (PickImageMergeViewModel.ImageState.Filter?) -> Unit,
    onTrailingFilterChange: (PickImageMergeViewModel.ImageState.Filter?) -> Unit,
) {
    var selectedTab by remember { mutableIntStateOf(0) }

    val currentFilter  = if (selectedTab == 0) leadingFilter  else trailingFilter
    val onFilterChange = if (selectedTab == 0) onLeadingFilterChange else onTrailingFilterChange

    Column(modifier = Modifier.padding(horizontal = 12.dp)) {
        // 이미지 선택 탭
        TabRow(
            selectedTabIndex = selectedTab,
            modifier         = Modifier.height(36.dp)
        ) {
            Tab(
                selected = selectedTab == 0,
                onClick  = { selectedTab = 0 },
                text     = { Text("왼쪽", style = MaterialTheme.typography.labelMedium) }
            )
            Tab(
                selected = selectedTab == 1,
                onClick  = { selectedTab = 1 },
                text     = { Text("오른쪽", style = MaterialTheme.typography.labelMedium) }
            )
        }

        Spacer(Modifier.height(8.dp))

        // 필터 칩 목록
        LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            item {
                FilterChip(
                    selected = currentFilter == null,
                    onClick  = { onFilterChange(null) },
                    label    = { Text("없음") }
                )
            }
            items(PickImageMergeViewModel.ImageState.Filter.entries.toList()) { filter ->
                FilterChip(
                    selected = currentFilter == filter,
                    onClick  = { onFilterChange(filter) },
                    label    = { Text(filter.label) }
                )
            }
        }
    }
}

// ── 합성 렌더링 ───────────────────────────────────────────────────────────────
private fun renderMerged(
    canvasWidthPx:  Int,
    canvasHeightPx: Int,
    leadingBitmap:  Bitmap,
    leadingState:   PickImageMergeViewModel.ImageState,
    trailingBitmap: Bitmap,
    trailingState:  PickImageMergeViewModel.ImageState,
    zOrder:         List<PickImageMergeViewModel.ImageOrder>,
): Bitmap {
    fun makeFrame(ox: Float, oy: Float, s: Float) = ImageFrame(
        left   = ox,
        top    = oy,
        right  = ox + AppConstants.THUMBNAIL_SIZE_WIDTH.toFloat() * s,
        bottom = oy + AppConstants.THUMBNAIL_SIZE_HEIGHT.toFloat() * s
    )

    // 필터 적용 (null 이면 원본 그대로)
    val filteredLeading  = leadingBitmap.applyFilter(leadingState.filter)
    val filteredTrailing = trailingBitmap.applyFilter(trailingState.filter)

    val leadingFrame  = makeFrame(leadingState.offsetX,  leadingState.offsetY,  leadingState.scale)
    val trailingFrame = makeFrame(trailingState.offsetX, trailingState.offsetY, trailingState.scale)

    val isLeadingBottom = zOrder.firstOrNull() == PickImageMergeViewModel.ImageOrder.BOTTOM
    val model = ImageMergerModel(
        canvasWidth  = canvasWidthPx,
        canvasHeight = canvasHeightPx,
        bottomImage  = ImageMergerModel.ImageInfo(
            image = if (isLeadingBottom) filteredLeading  else filteredTrailing,
            frame = if (isLeadingBottom) leadingFrame     else trailingFrame
        ),
        topImage     = ImageMergerModel.ImageInfo(
            image = if (isLeadingBottom) filteredTrailing else filteredLeading,
            frame = if (isLeadingBottom) trailingFrame    else leadingFrame
        ),
        blendAlpha   = 0.5f
    )

    return ImageMerger().merge(model)
}

// ── TransformableImage ────────────────────────────────────────────────────────
@Composable
private fun TransformableImage(
    bitmap:  ImageBitmap,
    offsetX: Float,
    offsetY: Float,
    scale:   Float,
    onDrag:  (dx: Float, dy: Float) -> Unit,
    onScale: (factor: Float) -> Unit,
) {
    val transformableState = rememberTransformableState { zoomChange, panChange, _ ->
        onDrag(panChange.x, panChange.y)
        onScale(zoomChange)
    }
    Image(
        bitmap             = bitmap,
        contentDescription = null,
        contentScale       = ContentScale.Crop,
        modifier           = Modifier
            .size(
                AppConstants.THUMBNAIL_SIZE_WIDTH.dp,
                AppConstants.THUMBNAIL_SIZE_HEIGHT.dp
            )
            .offset { IntOffset(offsetX.roundToInt(), offsetY.roundToInt()) }
            .scale(scale)
            .transformable(state = transformableState)
    )
}

private fun Bitmap.applyFilter(filter: PickImageMergeViewModel.ImageState.Filter?) : Bitmap {
    val mutableBitmap = this.copy(Bitmap.Config.ARGB_8888, true)

    val canvas = Canvas(mutableBitmap)
    var paint = Paint()

    when (filter) {
        PickImageMergeViewModel.ImageState.Filter.INVERTED -> {
            val matrix = ColorMatrix(floatArrayOf(
                -1f, 0f, 0f, 0f, 255f,
                0f, -1f, 0f, 0f, 255f,
                0f, 0f, -1f, 0f, 255f,
                0f, 0f, 0f, 1f, 0f
            ))
            paint.colorFilter = ColorMatrixColorFilter(
                matrix).asAndroidColorFilter()
            canvas.drawBitmap(mutableBitmap, 0f, 0f, paint)
            return mutableBitmap
        }
        PickImageMergeViewModel.ImageState.Filter.VIGNETTE -> {
            val centerX = canvas.width / 2f
            val centerY = canvas.height / 2f
            val radius = Math.max(centerX, centerY) * 1.2f
            val vignetteColor = 0x99000000.toInt()
            // 3. Create a RadialGradient (center fades out to the edges)
            val gradient = RadialGradient(
                centerX, centerY, radius,
                intArrayOf(0x00000000, 0x00000000, vignetteColor),
                floatArrayOf(0.0f, 0.6f, 1.0f),
                Shader.TileMode.CLAMP
            )
            paint = Paint().apply {
                isAntiAlias = true
                shader = gradient
                xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_OVER)
            }
            canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
            return mutableBitmap
        }
        PickImageMergeViewModel.ImageState.Filter.CONTRAST -> {
            val scale = 1.0f
            val translate = (-0.5f * scale + 0.5f) * 255f
            // 4x5 ColorMatrix Array
            val contrastMatrix = floatArrayOf(
                scale, 0f, 0f, 0f, translate,
                0f, scale, 0f, 0f, translate,
                0f, 0f, scale, 0f, translate,
                0f, 0f, 0f, 1f, 0f
            )
            paint.colorFilter = ColorMatrixColorFilter(
                ColorMatrix(contrastMatrix)).asAndroidColorFilter()
            canvas.drawBitmap(mutableBitmap, 0f, 0f, paint)
            return mutableBitmap
        }
        PickImageMergeViewModel.ImageState.Filter.SATURATION -> {
            paint.colorFilter = ColorMatrixColorFilter(
                ColorMatrix().apply { setToSaturation(1f) }).asAndroidColorFilter()
            canvas.drawBitmap(mutableBitmap, 0f, 0f, paint)
            return mutableBitmap
        }
        PickImageMergeViewModel.ImageState.Filter.MONOCHROME -> {
            paint.colorFilter = ColorMatrixColorFilter(
                ColorMatrix().apply { setToSaturation(0f) }).asAndroidColorFilter()
            canvas.drawBitmap(mutableBitmap, 0f, 0f, paint)
            return mutableBitmap
        }
        else -> {
            return this
        }
    }
}