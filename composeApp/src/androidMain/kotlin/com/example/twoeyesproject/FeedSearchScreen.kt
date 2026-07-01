package com.example.twoeyesproject

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SearchBar
import androidx.compose.material3.SearchBarDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.isTraversalGroup
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.traversalIndex
import androidx.core.graphics.colorSpace
import com.example.twoeyesproject.design.AppColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FeedSearchScreen(
    onBackButtonClick: () -> Unit = {},
    topAppBarDataChange: (TopAppBarData) -> Unit,
) {
    val textFieldState = TextFieldState(initialText = "")
    var query by rememberSaveable { mutableStateOf("") }
    var expanded by rememberSaveable { mutableStateOf(false) }

    SideEffect {
        topAppBarDataChange( TopAppBarData("", {
            SearchBar(
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { traversalIndex = 0f },
                inputField = {
                    SearchBarDefaults.InputField(
                        modifier = Modifier.background(Color(AppColors.Surface)),
                        query = textFieldState.text.toString(),
                        onQueryChange = { textFieldState.edit { replace(0, length, it) } },
                        onSearch = { expanded = false },
                        expanded = expanded,
                        onExpandedChange = { expanded = it },
                        leadingIcon = {
                            IconButton(onClick = {
                                query = ""
                                onBackButtonClick()
                            }) {
                                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "뒤로")
                            }
                        },
                        trailingIcon = {
                            if (query.isNotEmpty()) {
                                IconButton(onClick = { query = "" }) {
                                    Icon(Icons.Default.Close, contentDescription = "지우기")
                                }
                            }
                        },
                        placeholder = { Text("Search", color = Color(AppColors.TextSecondary)) }
                    )
                },
                expanded = expanded,
                onExpandedChange = { expanded = it },
            ) {

            }
        }) )
    }

    Column(modifier = Modifier
        .fillMaxHeight(1f)
        .verticalScroll(rememberScrollState())
    ) {
        // Display search results in a scrollable column
        Text("")
    }
}
