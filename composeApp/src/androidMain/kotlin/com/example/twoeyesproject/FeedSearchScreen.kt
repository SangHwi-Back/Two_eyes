package com.example.twoeyesproject

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.traversalIndex
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.rememberNavController
import coil3.compose.AsyncImage
import com.example.twoeyesproject.dependency.ApiClient
import com.example.twoeyesproject.design.AppColors
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.FeedSearchViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FeedSearchScreen(
    onBackButtonClick: () -> Unit = {},
    topAppBarDataChange: (TopAppBarData) -> Unit,
    viewModel: FeedSearchViewModel = viewModel()
) {
    var query by rememberSaveable { mutableStateOf("") }
    var expanded by rememberSaveable { mutableStateOf(false) }
    val navController = rememberNavController()
    val scope = rememberCoroutineScope()

    val searchResult by viewModel.listData.collectAsStateWithLifecycle()
    val featuredResult by viewModel.featuredData.collectAsStateWithLifecycle()

    SideEffect {
        scope.launch {
            viewModel.featuredFeeds()
        }
        topAppBarDataChange(
            TopAppBarData("", {}, visible = false)
        )
    }

    SearchBar(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .background(Color(AppColors.Surface))
            .semantics { traversalIndex = 0f },
        inputField = {
            SearchBarDefaults.InputField(
                modifier = Modifier.background(Color(AppColors.Surface2)),
                query = query,
                onQueryChange = { query = it },
                onSearch = { expanded = false },
                expanded = expanded,
                onExpandedChange = { expanded = it },
                leadingIcon = {
                    IconButton(onClick = {
                        if (query.isEmpty())
                            onBackButtonClick()
                        else
                            query = ""

                        viewModel.removeFeedResults()
                    }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "뒤로")
                    }
                },
                trailingIcon = {
                    IconButton(onClick = { scope.launch {
                        viewModel.searchFeeds(query)
                    } }) {
                        Icon(Icons.Default.Search, contentDescription = "검색")
                    }
                },
                placeholder = { Text("Search", color = Color(AppColors.TextSecondary)) }
            )
        },
        expanded = expanded,
        onExpandedChange = { expanded = it },
    ) {
        Column(modifier = Modifier
            .fillMaxHeight(1f)
            .verticalScroll(rememberScrollState())
        ) {
            searchResult.forEach { FeedSearchResultViewFrom(it) {
                navController.navigate(it)
            } }
        }
    }

    if (query.isEmpty() && searchResult.isEmpty()) {
        LazyVerticalGrid(
            modifier = Modifier
                .background(Color(AppColors.Background))
                .fillMaxWidth()
                .fillMaxHeight(1f),
            columns = GridCells.Adaptive(AppConstants.THUMBNAIL_SIZE_WIDTH.dp),
            contentPadding = PaddingValues(8.dp),
        ) {
            items(featuredResult) { FeedSearchResultViewFrom(it) {
                navController.navigate(it)
            } }
        }
    }
}

@Composable
fun FeedSearchResultViewFrom(item: FeedItemModel, onClick: () -> Unit) {
    val shape = RoundedCornerShape(AppConstants.CARD_CORNER_RADIUS)
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(8.dp))
            .background(Color(AppColors.Surface2), shape)
            .border(1.5.dp, Color.White, shape)
            .clickable(onClick = onClick),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AsyncImage(
            model = item.imageUrls.first(),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(
                    width = AppConstants.THUMBNAIL_SIZE_WIDTH.dp,
                    height = AppConstants.THUMBNAIL_SIZE_HEIGHT.dp
                )
                .clip(RoundedCornerShape(8.dp))
                .padding(end = 8.dp)
        )

        Column(
            horizontalAlignment = Alignment.Start,
        ) {
            Text("Author : ${item.author}", style = MaterialTheme.typography.titleMedium)
            Text("IsLiked : ${item.isUserLiked}", style = MaterialTheme.typography.bodyMedium)
            Text("Likes : ${item.likes}", style = MaterialTheme.typography.bodyMedium)
            Text("Replies : ${item.replyArray.size}", style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun FeedSearchScreenPreview() {
    FeedSearchScreen(
        onBackButtonClick = {},
        topAppBarDataChange = {},
        viewModel = FeedSearchViewModel(ApiClient())
    )
}