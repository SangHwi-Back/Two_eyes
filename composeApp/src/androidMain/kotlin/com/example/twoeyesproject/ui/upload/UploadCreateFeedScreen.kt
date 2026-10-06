package com.example.twoeyesproject.ui.upload

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.rememberNavController
import coil3.compose.AsyncImage
import com.example.twoeyesproject.TopAppBarBackButton
import com.example.twoeyesproject.TopAppBarData
import com.example.twoeyesproject.dependency.MergeResultEntity
import com.example.twoeyesproject.dependency.UploadMergedDTO
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.upload.UploadViewModel
import org.koin.androidx.compose.koinViewModel

@Composable
fun UploadCreateFeedScreen(
    viewModel: UploadViewModel = koinViewModel(),
    entity: MergeResultEntity,
    topAppBarDataChange: ((TopAppBarData) -> Unit)? = null,
) {
    val scrollState = rememberScrollState()
    val navController = rememberNavController()

    var dto by remember {
        mutableStateOf(
            UploadMergedDTO(
                listOf(entity.leadingImageId, entity.trailingImageId, entity.resultId),
                mutableListOf(),
                ""
            )
        )
    }
    var tagText by remember { mutableStateOf("") }

    SideEffect {
        topAppBarDataChange?.invoke(TopAppBarData(
            "New Feed",
            {
                IconButton(onClick = { navController.popBackStack() }) {
                    Icon(imageVector = Icons.Outlined.Close, contentDescription = "닫기")
                }
            },
            true,
            TopAppBarBackButton.Common
        ))
    }
    Column(
        Modifier
            .verticalScroll(scrollState)
            .background(color = Color(AppColors.Background))
    ) {
        SectionHeader("이미지", Icons.Outlined.Image, Color(AppColors.TextSecondary))
        Row(
            verticalAlignment = Alignment.Bottom
        ) {
            Text("합성 결과", color = Color.White, modifier = Modifier.fillMaxWidth(0.3f))

            AsyncImage(
                model = entity.resultId,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .size(200.dp)
                    .fillMaxWidth(0.3f)
            )

            Box(modifier = Modifier.fillMaxWidth(0.3f))
        }
        Row {
            Column(
                modifier = Modifier.fillMaxWidth(0.45f)
            ) {
                Text(text = "원본 1", modifier = Modifier.fillMaxWidth(1f))
                Row {
                    Spacer(modifier = Modifier.width(20.dp))
                    AsyncImage(
                        model = entity.leadingImageId,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.size(200.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.widthIn(min = 8.dp, max = 40.dp))

            Column(
                modifier = Modifier.fillMaxWidth(0.45f)
            ) {
                Text(text = "원본 2", modifier = Modifier.fillMaxWidth(1f))
                Row {
                    Spacer(modifier = Modifier.width(20.dp))
                    AsyncImage(
                        model = entity.trailingImageId,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.size(200.dp)
                    )
                }
            }
        }

        SectionHeader("내용", Icons.Outlined.Notes, Color(AppColors.TextSecondary))
        OutlinedTextField(
            value = dto.contents,
            onValueChange = { dto = dto.copy(contents = it) },
            label = { Text("이미지에 대한 이야기를 작성해보세요...") },
            maxLines = 4,
            modifier = Modifier
                .height(120.dp)
                .fillMaxWidth(1f)
        )

        SectionHeader("태그", Icons.Outlined.Label, Color(AppColors.TextSecondary))
        OutlinedTextField(
            value = tagText,
            onValueChange = { tagText = it },
            label = { Text("해시태그를 입력하세요") },
            keyboardActions = KeyboardActions(
                onDone = {
                    if (tagText.isNotBlank()) {
                        dto = dto.copy(tags = dto.tags.apply {
                            add(tagText)
                        })
                        tagText = ""
                    }
                }
            ),
            modifier = Modifier.fillMaxWidth(1f)
        )
    }
}

@Composable
fun SectionHeader(title: String, icon: ImageVector, textColor: Color) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, tint = textColor)
        Text(" $title", color = textColor)
    }
}