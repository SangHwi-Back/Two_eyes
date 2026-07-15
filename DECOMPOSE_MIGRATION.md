# Decompose 마이그레이션 가이드

Decompose는 KMP를 위한 강력한 네비게이션 및 라이프사이클 관리 라이브러리입니다. 비즈니스 로직과 UI를 완전히 분리하고, 복잡한 객체를 직렬화 없이 전달할 수 있습니다.

---

## 1. 의존성 추가

### `gradle/libs.versions.toml`

```toml
[versions]
decompose = "3.2.0"
essenty = "2.2.0"

[libraries]
decompose-core = { module = "com.arkivanov.decompose:decompose", version.ref = "decompose" }
decompose-compose = { module = "com.arkivanov.decompose:extensions-compose", version.ref = "decompose" }
essenty-lifecycle = { module = "com.arkivanov.essenty:lifecycle", version.ref = "essenty" }
essenty-state-keeper = { module = "com.arkivanov.essenty:state-keeper", version.ref = "essenty" }
essenty-back-handler = { module = "com.arkivanov.essenty:back-handler", version.ref = "essenty" }
```

### `shared/build.gradle.kts`

```kotlin
sourceSets {
    commonMain.dependencies {
        // 기존 의존성들...

        // Decompose
        implementation(libs.decompose.core)
        implementation(libs.essenty.lifecycle)
        implementation(libs.essenty.state.keeper)
        implementation(libs.essenty.back.handler)
    }
}
```

### `composeApp/build.gradle.kts`

```kotlin
sourceSets {
    androidMain.dependencies {
        // 기존 의존성들...

        // Decompose Compose Extensions
        implementation(libs.decompose.compose)
    }

    commonMain.dependencies {
        // 기존 의존성들...

        // Decompose Compose Extensions
        implementation(libs.decompose.compose)
    }
}
```

---

## 2. 핵심 개념

### Component
- 비즈니스 로직, 상태, 자식 컴포넌트 네비게이션을 담당
- `shared/commonMain`에 위치
- UI와 완전히 독립적

### Configuration
- 네비게이션의 각 "화면"을 나타내는 직렬화 가능한 데이터 클래스
- 복잡한 객체 전달 가능 (Parcelize/Serializable)

### Child Stack
- 네비게이션 스택 관리
- push, pop, replace 등의 작업 지원

---

## 3. 아키텍처 구조

```
shared/
└── src/commonMain/
    └── kotlin/com/example/twoeyesproject/
        ├── root/
        │   ├── RootComponent.kt           # 최상위 컴포넌트
        │   └── DefaultRootComponent.kt    # 구현체
        ├── feed/
        │   ├── FeedComponent.kt
        │   ├── DefaultFeedComponent.kt
        │   └── FeedListViewModel.kt       # 기존 ViewModel 유지
        ├── feeddetail/
        │   ├── FeedDetailComponent.kt
        │   └── DefaultFeedDetailComponent.kt
        └── upload/
            ├── UploadComponent.kt
            └── DefaultUploadComponent.kt

composeApp/
└── src/androidMain/
    └── kotlin/com/example/twoeyesproject/
        ├── App.kt                         # RootComponent 렌더링
        └── ui/
            ├── feed/
            │   └── FeedContent.kt         # @Composable UI only
            ├── feeddetail/
            │   └── FeedDetailContent.kt
            └── upload/
                └── UploadContent.kt
```

---

## 4. 단계별 마이그레이션

### Step 1: RootComponent 생성

**`shared/src/commonMain/.../root/RootComponent.kt`**

```kotlin
package com.example.twoeyesproject.root

import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.FeedComponent
import com.example.twoeyesproject.feeddetail.FeedDetailComponent
import com.example.twoeyesproject.upload.UploadComponent
import kotlinx.serialization.Serializable

interface RootComponent {

    val stack: Value<ChildStack<*, Child>>

    fun onBackClicked()

    sealed interface Child {
        data class Feed(val component: FeedComponent) : Child
        data class FeedDetail(val component: FeedDetailComponent) : Child
        data class Upload(val component: UploadComponent) : Child
        // 다른 화면들...
    }
}

@Serializable
sealed interface Config {
    @Serializable
    data object Feed : Config

    @Serializable
    data class FeedDetail(val feedId: String) : Config

    @Serializable
    data object Upload : Config

    @Serializable
    data object Camera : Config
}
```

**`shared/src/commonMain/.../root/DefaultRootComponent.kt`**

```kotlin
package com.example.twoeyesproject.root

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.DefaultFeedComponent
import com.example.twoeyesproject.feeddetail.DefaultFeedDetailComponent
import com.example.twoeyesproject.upload.DefaultUploadComponent

class DefaultRootComponent(
    componentContext: ComponentContext,
) : RootComponent, ComponentContext by componentContext {

    private val navigation = StackNavigation<Config>()

    override val stack: Value<ChildStack<*, RootComponent.Child>> =
        childStack(
            source = navigation,
            serializer = Config.serializer(),
            initialConfiguration = Config.Feed,
            handleBackButton = true,
            childFactory = ::child,
        )

    private fun child(config: Config, componentContext: ComponentContext): RootComponent.Child =
        when (config) {
            is Config.Feed -> RootComponent.Child.Feed(
                DefaultFeedComponent(
                    componentContext = componentContext,
                    onFeedClick = { feedId ->
                        navigation.push(Config.FeedDetail(feedId))
                    },
                    onSearchClick = {
                        // navigation.push(Config.FeedSearch)
                    }
                )
            )

            is Config.FeedDetail -> RootComponent.Child.FeedDetail(
                DefaultFeedDetailComponent(
                    componentContext = componentContext,
                    feedId = config.feedId,
                    onBack = { navigation.pop() }
                )
            )

            is Config.Upload -> RootComponent.Child.Upload(
                DefaultUploadComponent(
                    componentContext = componentContext,
                    onNext = { /* ... */ }
                )
            )

            is Config.Camera -> {
                // TODO: Camera component
                RootComponent.Child.Feed(
                    DefaultFeedComponent(componentContext, {}, {})
                )
            }
        }

    override fun onBackClicked() {
        navigation.pop()
    }
}
```

---

### Step 2: FeedComponent 생성

**`shared/src/commonMain/.../feed/FeedComponent.kt`**

```kotlin
package com.example.twoeyesproject.feed

import com.arkivanov.decompose.value.Value
import com.example.twoeyesproject.feed.FeedItemModel
import kotlinx.coroutines.flow.StateFlow

interface FeedComponent {
    val items: StateFlow<List<FeedItemModel>>

    fun onFeedClick(feedId: String)
    fun onSearchClick()
    fun onLikeClick(feedId: String)
}
```

**`shared/src/commonMain/.../feed/DefaultFeedComponent.kt`**

```kotlin
package com.example.twoeyesproject.feed

import com.arkivanov.decompose.ComponentContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.StateFlow
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class DefaultFeedComponent(
    componentContext: ComponentContext,
    private val onFeedClick: (String) -> Unit,
    private val onSearchClick: () -> Unit,
) : FeedComponent, ComponentContext by componentContext, KoinComponent {

    private val viewModel: FeedListViewModel by inject()

    // ComponentContext의 lifecycle을 사용한 Coroutine Scope
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override val items: StateFlow<List<FeedItemModel>> = viewModel.listData

    init {
        // 피드 로드
        viewModel.getAllFeeds()

        // Component가 destroy될 때 scope 취소
        lifecycle.doOnDestroy {
            scope.cancel()
        }
    }

    override fun onFeedClick(feedId: String) {
        onFeedClick.invoke(feedId)
    }

    override fun onSearchClick() {
        onSearchClick.invoke()
    }

    override fun onLikeClick(feedId: String) {
        viewModel.updateLike(true, feedId)
    }
}
```

---

### Step 3: FeedDetailComponent 생성

**`shared/src/commonMain/.../feeddetail/FeedDetailComponent.kt`**

```kotlin
package com.example.twoeyesproject.feeddetail

import com.example.twoeyesproject.feed.FeedItemModel
import kotlinx.coroutines.flow.StateFlow

interface FeedDetailComponent {
    val feedId: String
    val feedItem: StateFlow<FeedItemModel?>

    fun onBackClick()
    fun onLikeClick()
}
```

**`shared/src/commonMain/.../feeddetail/DefaultFeedDetailComponent.kt`**

```kotlin
package com.example.twoeyesproject.feeddetail

import com.arkivanov.decompose.ComponentContext
import com.example.twoeyesproject.feed.FeedItemModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.koin.core.component.KoinComponent

class DefaultFeedDetailComponent(
    componentContext: ComponentContext,
    override val feedId: String,
    private val onBack: () -> Unit,
) : FeedDetailComponent, ComponentContext by componentContext, KoinComponent {

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val _feedItem = MutableStateFlow<FeedItemModel?>(null)
    override val feedItem: StateFlow<FeedItemModel?> = _feedItem

    init {
        // feedId로 데이터 로드
        scope.launch {
            // TODO: Repository에서 feedId로 데이터 가져오기
            // _feedItem.value = repository.getFeedById(feedId)
        }

        lifecycle.doOnDestroy {
            scope.cancel()
        }
    }

    override fun onBackClick() {
        onBack()
    }

    override fun onLikeClick() {
        // TODO: 좋아요 처리
    }
}
```

---

### Step 4: Android App에서 렌더링

**`composeApp/src/androidMain/.../App.kt`**

```kotlin
package com.example.twoeyesproject

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import com.arkivanov.decompose.extensions.compose.stack.Children
import com.arkivanov.decompose.extensions.compose.stack.animation.slide
import com.arkivanov.decompose.extensions.compose.stack.animation.stackAnimation
import com.arkivanov.decompose.extensions.compose.subscribeAsState
import com.example.twoeyesproject.root.RootComponent
import com.example.twoeyesproject.ui.feed.FeedContent
import com.example.twoeyesproject.ui.feeddetail.FeedDetailContent
import com.example.twoeyesproject.ui.upload.UploadContent

@Composable
fun RootContent(component: RootComponent) {
    val stack by component.stack.subscribeAsState()

    Children(
        stack = stack,
        animation = stackAnimation(slide()),
    ) {
        when (val child = it.instance) {
            is RootComponent.Child.Feed -> FeedContent(component = child.component)
            is RootComponent.Child.FeedDetail -> FeedDetailContent(component = child.component)
            is RootComponent.Child.Upload -> UploadContent(component = child.component)
        }
    }
}
```

**`composeApp/src/androidMain/.../MainActivity.kt`**

```kotlin
package com.example.twoeyesproject

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import com.arkivanov.decompose.defaultComponentContext
import com.example.twoeyesproject.root.DefaultRootComponent

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val rootComponent = DefaultRootComponent(
            componentContext = defaultComponentContext()
        )

        setContent {
            MaterialTheme {
                RootContent(component = rootComponent)
            }
        }
    }
}
```

**`composeApp/src/androidMain/.../ui/feed/FeedContent.kt`**

```kotlin
package com.example.twoeyesproject.ui.feed

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import com.example.twoeyesproject.feed.FeedComponent

@Composable
fun FeedContent(component: FeedComponent) {
    val items by component.items.collectAsState()

    LazyColumn {
        items(items) { item ->
            FeedItemCard(
                item = item,
                onItemClick = { component.onFeedClick(item.feedId) },
                onLikeClick = { component.onLikeClick(item.feedId) }
            )
        }
    }
}
```

---

### Step 5: iOS 지원 (SwiftUI)

**`iosApp/iosApp/iOSApp.swift`**

```swift
import SwiftUI
import Shared

@main
struct iOSApp: App {
    @StateObject private var holder = ComponentHolder()

    var body: some Scene {
        WindowGroup {
            RootView(component: holder.component)
        }
    }
}

class ComponentHolder: ObservableObject {
    let component: RootComponent

    init() {
        component = DefaultRootComponent(
            componentContext: DefaultComponentContext(lifecycle: ApplicationLifecycle())
        )
    }
}
```

**`iosApp/iosApp/RootView.swift`**

```swift
import SwiftUI
import Shared

struct RootView: View {
    let component: RootComponent

    @StateValue
    private var stack: ChildStack<AnyObject, RootComponentChild>

    init(component: RootComponent) {
        self.component = component
        _stack = StateValue(component.stack)
    }

    var body: some View {
        let child = stack.active.instance

        switch child {
        case let child as RootComponentChild.Feed:
            FeedView(component: child.component)
        case let child as RootComponentChild.FeedDetail:
            FeedDetailView(component: child.component)
        case let child as RootComponentChild.Upload:
            UploadView(component: child.component)
        default:
            EmptyView()
        }
    }
}
```

---

## 5. 마이그레이션 체크리스트

- [ ] 의존성 추가 (`gradle/libs.versions.toml`, `build.gradle.kts`)
- [ ] `RootComponent` 및 `DefaultRootComponent` 구현
- [ ] 각 화면별 `Component` 인터페이스 및 구현체 작성
- [ ] 기존 ViewModel을 Component에서 사용하도록 통합
- [ ] Android `App.kt` 및 `MainActivity.kt` 수정
- [ ] Compose UI를 `*Content.kt`로 분리 (Component를 파라미터로 받음)
- [ ] iOS `iOSApp.swift` 및 `RootView.swift` 구현
- [ ] 네비게이션 로직을 Component로 이동
- [ ] Jetpack Navigation 제거 (`androidx.navigation.compose` 의존성 삭제)
- [ ] 테스트 작성 (Component는 UI 없이 테스트 가능)

---

## 6. 장점 정리

✅ **완전한 KMP 지원** — Android, iOS, Desktop, Web 모두 동일한 네비게이션 로직
✅ **복잡한 객체 전달** — URL 직렬화 불필요, 직접 전달 가능
✅ **비즈니스 로직과 UI 분리** — Component는 플랫폼 독립적
✅ **라이프사이클 관리** — `Essenty Lifecycle`로 Android/iOS 라이프사이클 통합
✅ **테스트 용이성** — UI 없이 Component 단위 테스트 가능
✅ **Back Stack 제어** — 복잡한 네비게이션 시나리오 지원 (replace, popTo 등)

---

## 7. 참고 자료

- [Decompose 공식 문서](https://arkivanov.github.io/Decompose/)
- [Decompose GitHub](https://github.com/arkivanov/Decompose)
- [Sample 프로젝트](https://github.com/arkivanov/Decompose/tree/master/sample)
- [Essenty](https://github.com/arkivanov/Essenty) — 라이프사이클 및 상태 관리 유틸리티
