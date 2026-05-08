package com.example.twoeyesproject.ui.upload

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.input.KeyboardActionHandler
import androidx.compose.foundation.text.input.TextFieldLineLimits
import androidx.compose.foundation.text.input.clearText
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowForward
import androidx.compose.material.icons.automirrored.outlined.NoteAdd
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.ui.camera.BottomButton
import com.example.twoeyesproject.upload.UploadViewModel

@Composable
fun UploadCreateFeedView(
    viewModel: UploadViewModel,
    entity: MergeResultEntity
) {
    val scrollState = rememberScrollState()

    val tagFieldState = rememberTextFieldState("")
    val dto: UploadMergedDTO by remember {
        mutableStateOf(UploadMergedDTO(
            imageIds = listOf(
                entity.leadingImageId, entity.trailingImageId, entity.resultId
            ),
            tags = mutableListOf(),
            contents = ""
        ))
    }
    Column(
        Modifier
            .verticalScroll(scrollState)
            .background(color = Color(AppColors.Background))
    ) {
        OutlinedTextField(
            state = rememberTextFieldState(dto.contents),
            label = { Text("Contents") },
            lineLimits = TextFieldLineLimits.SingleLine,
        )

        OutlinedTextField(
            state = tagFieldState,
            label = { Text("Tag") },
            lineLimits = TextFieldLineLimits.SingleLine,
            trailingIcon = {
                Icon(
                    imageVector = Icons.AutoMirrored.Outlined.NoteAdd,
                    contentDescription = null,
                    tint = Color(AppColors.Surface2)
                )
            },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
            onKeyboardAction = KeyboardActionHandler {
                dto.tags.add(tagFieldState.text.toString())
                tagFieldState.clearText()
            }
        )

        // ── 썸네일 캐러셀: viewModel.imageSources 수집 (iOS: 비어있으면 height=0) ──
        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .height(if (dto.imageIds.isEmpty()) 0.dp else 190.dp)
                .padding(horizontal = 16.dp)
                .padding(bottom = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(dto.imageIds) { imageSource ->
                AsyncImage(
                    model = imageSource,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .width(120.dp)
                        .fillMaxHeight()
                        .clip(RoundedCornerShape(8.dp))
//                        .clickable { onThumbnailSelected(imageSource) }
                )
            }
        }

        BottomButton(
            icon = {
                Icon(
                    imageVector = Icons.AutoMirrored.Outlined.ArrowForward,
                    contentDescription = null,
                    tint = Color(AppColors.Surface2)
                )
            },
            label = "Next",
            onClick = { viewModel.uploadEntity(dto) }
        )
    }
}