package com.example.twoeyesproject.ui.upload

import android.net.Uri
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.GridView
import androidx.compose.material.icons.outlined.ViewList
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.upload.UploadViewModel

// size()가 exact 크기를 강제하므로 sizeIn은 불필요
private val ButtonSizeModifier = Modifier.size(width = 80.dp, height = 42.dp)

enum class UploadListTapType {
    DELETE, UPLOAD
}

enum class UploadListType {
    LIST, GRID
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UploadScreen(
    viewModel: UploadViewModel = viewModel()
) {
    val entities by viewModel.mergeEntities.collectAsStateWithLifecycle()
    // val → var: 전환 가능하도록
    var listType by remember { mutableStateOf(UploadListType.LIST) }

    fun onTap(type: UploadListTapType, entity: MergeResultEntity) {
        when (type) {
            UploadListTapType.DELETE -> viewModel.deleteEntity(entity)
            UploadListTapType.UPLOAD -> viewModel.uploadEntity(entity)
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Upload") },
                actions = {
                    IconButton(onClick = { listType = UploadListType.LIST }) {
                        Icon(Icons.Outlined.ViewList, contentDescription = "리스트 보기")
                    }
                    IconButton(onClick = { listType = UploadListType.GRID }) {
                        Icon(Icons.Outlined.GridView, contentDescription = "그리드 보기")
                    }
                }
            )
        }
    ) { innerPadding ->
        when (listType) {
            UploadListType.LIST -> LazyColumn(contentPadding = innerPadding) {
                items(entities) { entity ->
                    UploadScreenListCard(entity) { tapType -> onTap(tapType, entity) }
                }
            }
            UploadListType.GRID -> LazyVerticalGrid(
                columns = GridCells.Adaptive(128.dp),
                contentPadding = innerPadding
            ) {
                items(entities) { entity ->
                    UploadScreenGridCard(entity) { tapType -> onTap(tapType, entity) }
                }
            }
        }
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
            ImageSlot(uri = entity.leadingImageId.toUri(),  modifier = Modifier.weight(1f).fillMaxHeight())
            ImageSlot(uri = entity.trailingImageId.toUri(), modifier = Modifier.weight(1f).fillMaxHeight())
            ImageSlot(uri = entity.resultId.toUri(),        modifier = Modifier.weight(1f).fillMaxHeight())
        }

        OutlinedButton(
            modifier = ButtonSizeModifier.padding(start = 8.dp),
            onClick = { onClick(UploadListTapType.DELETE) }
        ) {
            Text("Delete")
        }

        FilledTonalButton(
            modifier = ButtonSizeModifier.padding(start = 8.dp),
            onClick = { onClick(UploadListTapType.UPLOAD) }
        ) {
            Text("Upload")
        }
    }
}

@Composable
private fun UploadScreenGridCard(
    entity: MergeResultEntity,
    onClick: (UploadListTapType) -> Unit
) {
    Column(
        modifier = Modifier.padding(4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
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

        FilledTonalButton(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 4.dp, bottom = 8.dp),
            onClick = { onClick(UploadListTapType.UPLOAD) }
        ) {
            Text("Upload")
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
