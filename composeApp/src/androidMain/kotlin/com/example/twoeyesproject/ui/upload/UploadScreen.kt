package com.example.twoeyesproject.ui.upload

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ViewList
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.GridView
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
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
import org.koin.androidx.compose.koinViewModel
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

// size()가 exact 크기를 강제하므로 sizeIn은 불필요
private val ButtonSizeModifier = Modifier.size(width = 80.dp, height = 42.dp)

enum class UploadListTapType {
    DELETE, LIST
}

enum class UploadListType {
    LIST, GRID
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

    Column(modifier = Modifier
        .background(color = Color(AppColors.Background))
    ) {
        when (listType) {
            UploadListType.LIST -> {
                if (entities.isEmpty())
                    Text(text = "Add Items!", color = Color.White)
                else
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
                if (entities.isEmpty())
                    Text(text = "Add Items!", color = Color.White)
                else
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
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(AppColors.Surface))
            .height(128.dp)
            .padding(horizontal = 16.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 이미지 영역: weight(1f)로 버튼 공간을 남기고 나머지를 차지
        Row(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                // clip 먼저 적용 후 border에 shape 지정해야 둥근 테두리가 그려짐
                .clip(RoundedCornerShape(8.dp))
                .border(1.dp, Color(AppColors.Primary.toInt()), RoundedCornerShape(8.dp)),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            ImageSlot(uri = entity.leadingImageId.toUri(),  modifier = Modifier
                .weight(1f)
                .fillMaxHeight())
            ImageSlot(uri = entity.trailingImageId.toUri(), modifier = Modifier
                .weight(1f)
                .fillMaxHeight())
            ImageSlot(uri = entity.resultId.toUri(),        modifier = Modifier
                .weight(1f)
                .fillMaxHeight())
        }

        OutlinedButton(
            modifier = ButtonSizeModifier.padding(start = 8.dp),
            onClick = { onClick(UploadListTapType.DELETE) }
        ) {
            Text("Delete")
        }
    }
}

@Composable
private fun UploadScreenGridCard(
    entity: MergeResultEntity,
    onClick: (UploadListTapType) -> Unit
) {
    Column(
        modifier = Modifier
            .padding(4.dp)
            .background(Color(AppColors.Surface)),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
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
