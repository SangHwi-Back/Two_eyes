package com.example.twoeyesproject.ui.upload

import android.net.Uri
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
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
import com.example.twoeyesproject.ui.camera.CameraScreenTapType
import com.example.twoeyesproject.upload.UploadViewModel

private val ButtonSizeModifier = Modifier
    .size(width = 80.dp, height = 42.dp)
    .sizeIn(maxWidth = 150.dp)

enum class UploadListTapType {
    DELETE, UPLOAD
}

enum class UploadListType {
    LIST, GRID
}

@Composable
fun UploadScreen(
    viewModel: UploadViewModel = viewModel()
) {
    // item 모두 가져오기
    viewModel.getAllEntities()

    val entities by viewModel.mergeEntities.collectAsStateWithLifecycle()
    val listType by remember { mutableStateOf(UploadListType.LIST) }

    fun onTap(type: UploadListTapType, entity: MergeResultEntity) {
        when (type) {
            UploadListTapType.DELETE -> viewModel.deleteEntity(entity)
            UploadListTapType.UPLOAD -> viewModel.uploadEntity(entity)
        }
    }

    when (listType) {
        UploadListType.LIST -> LazyColumn {
            items(entities) { UploadScreenListCard(it) { tapType ->
                onTap(tapType, it)
            } }
        }
        UploadListType.GRID -> LazyVerticalGrid(
            GridCells.Adaptive(128.dp)
        ) {
            items(entities) { UploadScreenGridCard(it) { tapType ->
                onTap(tapType, it)
            }  }
        }
    }
}


@Composable
private fun UploadScreenListCard(
    entity: MergeResultEntity,
    onClick: ((UploadListTapType) -> Unit)?
) {
    Column(modifier = Modifier.height(128.dp)) {
        Row {
            Row(
                modifier = Modifier
                    .border(width = 1.dp, color = Color(AppColors.Primary))
                    .clip(RoundedCornerShape(8.dp)),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                ImageSlot(
                    uri = entity.leadingImageId.toUri(),
                    modifier = Modifier.aspectRatio(1.6f))
                ImageSlot(
                    uri = entity.trailingImageId.toUri(),
                    modifier = Modifier.aspectRatio(1.6f))
                ImageSlot(
                    uri = entity.resultId.toUri(),
                    modifier = Modifier.aspectRatio(1.6f))
            }
            OutlinedButton(
                modifier = ButtonSizeModifier
                    .padding(8.dp),
                onClick = { if (onClick != null) onClick(UploadListTapType.DELETE) },
            ) {
                Text("Delete")
            }
            FilledTonalButton(
                modifier = ButtonSizeModifier
                    .padding(8.dp),
                onClick = { if (onClick != null) onClick(UploadListTapType.UPLOAD) },
            ) {
                Text("Upload")
            }
        }
    }
}

@Composable
private fun UploadScreenGridCard(
    entity: MergeResultEntity,
    onClick: ((UploadListTapType) -> Unit)?
) {
    Column(modifier = Modifier.height(128.dp)) {
        Box(Modifier.padding(vertical = 8.dp)) {
            ImageSlot(
                uri = entity.leadingImageId.toUri(),
                modifier = Modifier.aspectRatio(1f))
            IconButton(
                onClick = { if (onClick != null) onClick(UploadListTapType.DELETE) },
                modifier = ButtonSizeModifier.align(Alignment.TopStart)
            ) {
                Icon(Icons.Outlined.Delete, contentDescription = "좋아요")
            }
        }

        FilledTonalButton(
            modifier = ButtonSizeModifier.padding(bottom = 8.dp),
            onClick = { if (onClick != null) onClick(UploadListTapType.UPLOAD) },
        ) {
            Text("Upload")
        }
    }
}

@Composable
private fun ImageSlot(
    uri: Uri,
    modifier: Modifier = Modifier,
    onClick: ((CameraScreenTapType) -> Unit)? = null,
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(8.dp))
            .clickable { if (onClick != null) onClick(CameraScreenTapType.Highlight) },
        contentAlignment = Alignment.Center
    ) {
        AsyncImage(
            model = ImageRequest.Builder(LocalContext.current)
                .data(uri)
                .crossfade(true)
                .build(),
            contentDescription = "",
            modifier = Modifier.fillMaxSize())
    }
}
