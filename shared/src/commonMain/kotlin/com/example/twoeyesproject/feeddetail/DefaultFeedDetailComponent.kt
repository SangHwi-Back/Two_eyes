package com.example.twoeyesproject.feeddetail

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.essenty.lifecycle.doOnDestroy
import com.example.twoeyesproject.feed.FeedItemModel
import com.example.twoeyesproject.feed.FeedListViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import kotlin.getValue

class DefaultFeedDetailComponent(
    componentContext: ComponentContext,
    private val onBack: () -> Unit,
) : FeedDetailComponent, ComponentContext by componentContext, KoinComponent {
    private val viewModel: FeedListViewModel by inject()
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val _feedItem = MutableStateFlow<FeedItemModel?>(null)
    override val feedItem: StateFlow<FeedItemModel?> = _feedItem

    init {
        scope.launch {
            // TODO: Fetch feed item based on feedId
        }

        lifecycle.doOnDestroy { scope.cancel() }
    }

    override fun onBackClick() {
        onBack()
    }

    override fun onLikeClick() {
        feedItem.value?.let {
            if (feedItem.value != null) {
                scope.launch {
                    viewModel.updateLike(it.isUserLiked, feedId = it.feedId)
                }
            }
        }
    }
}