package com.example.twoeyesproject.feed

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.essenty.lifecycle.doOnDestroy
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class DefaultFeedComponent(
    componentContext: ComponentContext,
    private val onFeedClick: (String) -> Unit,
    private val onSearchClick: () -> Unit,
) : FeedComponent, ComponentContext by componentContext , KoinComponent {
    private val viewModel: FeedListViewModel by inject()

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override val items: StateFlow<List<FeedItemModel>> =
        viewModel.listData

    init {
        scope.launch {
            viewModel.getAllFeeds()
        }

        lifecycle.doOnDestroy { scope.cancel() }
    }
    override fun onFeedClick(feedId: String) {
        onFeedClick.invoke(feedId)
    }

    override fun onSearchClick() {
        onSearchClick.invoke()
    }

    override fun onLikeClick(feedId: String) {
        scope.launch {
            viewModel.updateLike(true, feedId)
        }
    }
}