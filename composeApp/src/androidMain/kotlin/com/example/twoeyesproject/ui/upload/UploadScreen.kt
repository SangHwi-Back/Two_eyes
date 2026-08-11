package com.example.twoeyesproject.ui.upload

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ViewList
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.GridView
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import com.example.twoeyesproject.AppConstants
import com.example.twoeyesproject.TopAppBarData
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.upload.UploadViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import org.koin.androidx.compose.koinViewModel

enum class UploadListTapType {
    DELETE,
    LIST
}

enum class UploadListType {
    LIST,
    GRID
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UploadScreen(
    viewModel: UploadViewModel = koinViewModel(),
    onNext: (MergeResultEntity) -> Unit,
    topAppBarDataChange: ((TopAppBarData) -> Unit)? = null,
) {
    val entities by viewModel.mergeEntities.collectAsStateWithLifecycle()
    var listType by remember { mutableStateOf(UploadListType.LIST) }
    val scope = rememberCoroutineScope()

    fun onTap(type: UploadListTapType, entity: MergeResultEntity) {
        when (type) {
            UploadListTapType.DELETE -> {
                scope.launch {
                    viewModel.deleteEntity(entity)
                }
            }
            UploadListTapType.LIST -> onNext(entity)
        }
    }

    val innerPadding = 8.dp

    Column(Modifier.background(color = Color(AppColors.Background))) {
        if (entities.isEmpty())
            Text(text = "Add Items!", color = Color.White)
        else
            when (listType) {
                UploadListType.LIST -> {
                    LazyColumn(
                        contentPadding = PaddingValues(innerPadding),
                        modifier = Modifier.background(Color(AppColors.Background)),
                    ) {
                        items(entities) { entity ->
                            UploadScreenListCard(entity) { tapType -> onTap(tapType, entity) }
                        }
                    }
                }
                UploadListType.GRID -> {
                    LazyVerticalGrid(
                        columns = GridCells.Adaptive(AppConstants.THUMBNAIL_SIZE_WIDTH.dp),
                        contentPadding = PaddingValues(innerPadding),
                        modifier = Modifier.background(Color(AppColors.Background)),
                    ) {
                        items(entities) { entity ->
                            UploadScreenGridCard(entity) { tapType -> onTap(tapType, entity) }
                        }
                    }
                }
            }
    }

    SideEffect {
        topAppBarDataChange?.invoke(TopAppBarData("Upload", {
            IconButton(onClick = { listType = UploadListType.LIST }) {
                Icon(Icons.AutoMirrored.Outlined.ViewList, contentDescription = "리스트 보기")
            }
            IconButton(onClick = { listType = UploadListType.GRID }) {
                Icon(Icons.Outlined.GridView, contentDescription = "그리드 보기")
            }
        }))
    }
}

@Composable
private fun UploadScreenListCard(
    entity: MergeResultEntity,
    onClick: (UploadListTapType) -> Unit
) {
    val scrollState = rememberScrollState()

    Row(
        modifier = Modifier
            .fillMaxWidth(1f)
            .clip(RoundedCornerShape(8.dp))
            .border(1.dp, Color(AppColors.Primary.toInt()), RoundedCornerShape(8.dp))
            .clickable { onClick(UploadListTapType.LIST) }
            .horizontalScroll(scrollState)
            .padding(horizontal = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        ImageSlot(
            uri = entity.leadingImageId.toUri(),
            modifier = Modifier
                .size(76.dp)
                .padding(vertical = 8.dp)
        )

        ImageSlot(
            uri = entity.trailingImageId.toUri(),
            modifier = Modifier
                .size(width = 36.dp, height = 36.dp)
                .padding(horizontal = 8.dp)
        )

        ImageSlot(
            uri = entity.resultId.toUri(),
            modifier = Modifier
                .size(width = 36.dp, height = 36.dp)
        )

        Spacer(Modifier
            .weight(1f)
            .defaultMinSize(minWidth = 8.dp)
        )

        OutlinedButton(
            modifier = Modifier
                .aspectRatio(1.5f)
                .padding(horizontal = 8.dp),
            onClick = { onClick(UploadListTapType.DELETE) },
            colors = ButtonColors(
                contentColor = Color.Red,
                containerColor = Color.Red,
                disabledContainerColor = Color.Transparent,
                disabledContentColor = Color.Transparent
            ),
        ) {
            Text(
                color = Color.White,
                text = "Delete"
            )
        }
    }
}

@Composable
private fun UploadScreenGridCard(
    entity: MergeResultEntity,
    onClick: (UploadListTapType) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1f)
            .padding(4.dp)
            .background(Color(AppColors.Surface))
            .clip(RoundedCornerShape(8.dp))
    ) {
        ImageSlot(
            uri = entity.resultId.toUri(),
            modifier = Modifier.fillMaxSize()
        )
        // Delete 아이콘을 이미지 위에 오버레이
        IconButton(
            onClick = { onClick(UploadListTapType.DELETE) },
            modifier = Modifier.align(Alignment.TopEnd)
        ) {
            Icon(Icons.Outlined.Delete, contentDescription = "삭제")
        }
    }
}

@Composable
private fun ImageSlot(
    uri: Uri,
    modifier: Modifier = Modifier,
) {
    AsyncImage(
        model = ImageRequest.Builder(LocalContext.current)
            .data(uri)
            .crossfade(true)
            .build(),
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun UploadScreenPreview() {
    UploadScreen(
        viewModel = koinViewModel<UploadViewModel>().apply {
            mergeEntities = dao.getAllAsFlow().stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(0),
                initialValue = listOf(
                    MergeResultEntity(0, "", "", "", null, "", false)
                )
            )
        },
        onNext = {}
    )
}
