import SwiftUI
import Photos
import Shared

struct ContentView: View {
    @Environment(\.apiClient) var apiClient
    @Environment(\.userData) var userData
    
    @State private var isSearching = false
    @State private var showLogin = false
    @Environment(\.rootViewController) var rootViewController: UIViewController
    @Environment(\.applyNavigationBarAppearance) var applyNavigationBarAppearance
    
    // Making the @StateObject a computed property or accessing it differently
    @StateObject private var holder = ComponentHolder(tab: .feed)
    
    private var overlayComponent: OverlayComponent {
        holder.component.overlayComponent
    }
    
    var body: some View {
        TabView(selection: $holder.currentTab) {
            // MARK: Feed
            Tab("Feed", systemImage: "text.below.photo", value: .feed) {
                FeedTabContentView(component: holder.component.feedTab,
                                   showLogin: $showLogin)
            }
            // MARK: Camera
            Tab("Camera", systemImage: "camera", value: .camera) {
                PickImageTabContentView(component: holder.component.pickImageTab,
                                        showLogin: $showLogin)
            }
            // MARK: Upload
            Tab("Upload", systemImage: "square.and.arrow.up", value: .upload) {
                UploadTabContentView(component: holder.component.uploadTab,
                                     showLogin: $showLogin)
            }
            // MARK: Search
            if holder.currentTab == .feed {
                Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                    EmptyView()
                }
            }
        }
        .fullScreenCover(isPresented: $isSearching) {
            SearchModalView(
                tabSelection: $holder.currentTab,
                apiClient: apiClient
            )
        }
        .onChange(of: holder.currentTab) { _, newValue in
            isSearching = newValue == .search
            if newValue != .search {
                onTabButtonClicked(from: newValue)
            }
        }
        .task {
            applyNavigationBarAppearance()
            
            let storage = PlatformSecureStorage()
            
            if let appleData = storage.getAppleUserData() {
                self.userData.wrappedValue = .apple(appleData)
            } else if let googleData = storage.getGoogleUserData() {
                self.userData.wrappedValue = .google(googleData)
            } else {
                Task {
                    let viewModel = LoginViewModel(context: rootViewController)
                    let result = try? await viewModel.googleCheckState(credential: "")
                    if let result = result as? LoginStatusCheckResult.Authorized,
                       let googleData = result.userInfo as? SecureUserData.GoogleUserData
                    {
                        self.userData.wrappedValue = .google(googleData)
                    }
                }
            }
        }
        .loginOverlay(overlayView: $holder.overlayView, showLogin: $showLogin)
    }
    
    private func onTabButtonClicked(from tab: TabSelection) {
        switch tab {
        case .feed:
            holder.component.onTabButtonClicked(
                tab: ConfigFeed(), goBackWhenSameTab: true)
        case .camera:
            holder.component.onTabButtonClicked(
                tab: ConfigPickImage(), goBackWhenSameTab: false)
        case .upload:
            holder.component.onTabButtonClicked(
                tab: ConfigUpload(), goBackWhenSameTab: true)
        case .search:
            return
        }
    }
}

struct LoginToolbarItem: ToolbarContent {
    @Environment(\.userData) var userData
    var showLogin: Binding<Bool>

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showLogin.wrappedValue = true
            } label: {
                let isLoggedIn = userData.wrappedValue != nil
                let systemName = "person.fill.\(isLoggedIn ? "checkmark" : "questionmark")"
                let foregroundColor: Int64 = isLoggedIn
                    ? AppColors.shared.Primary
                    : AppColors.shared.Secondary

                Image(systemName: systemName)
                    .imageScale(.large)
                    .foregroundStyle(foregroundColor.color)
            }
        }
    }
}

// MARK: - Kotlin ARGB Long → SwiftUI Color

extension Int64 {
    var color: Color {
        let argb  = UInt32(self & 0xFFFFFFFF)
        let alpha = Double((argb >> 24) & 0xFF) / 255.0
        let red   = Double((argb >> 16) & 0xFF) / 255.0
        let green = Double((argb >> 8)  & 0xFF) / 255.0
        let blue  = Double(argb         & 0xFF) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - NavHost 라우트 정의

enum NavHost {
    case feed(Feed)
    case camera(Camera)
    case upload(Upload)
    
    enum Feed: Hashable {
        case main
    }
    
    enum Camera: Hashable {
        case main
        case merge(PHAsset, PHAsset)
    }
    
    enum Upload: Hashable {
        case main(AppDatabase)
        case upload(MergeResultEntity, UploadViewModel)
    }
}

enum TabSelection: Hashable {
    case feed, camera, upload, search
}

enum OverlayView: Hashable, Identifiable {
    var id: Self { self }
    case none, login
}

// MARK: - NavigationPathObject

class NavigationPathObject<T: Hashable>: ObservableObject {
    @Published var path: [T]
    
    /// popToRoot() 호출 시 실행할 콜백.
    /// 루트 뷰의 onAppear 에서 등록해 두면 onChange 없이 상태를 초기화할 수 있습니다.
    var onPopToRoot: (() -> Void)?
    
    @MainActor func push(to type: T) { path.append(type) }
    @MainActor func pop()            { path.removeLast() }
    @MainActor func popToRoot() {
        path.removeAll()
        onPopToRoot?()
    }
    
    init(path: [T]) { self.path = path }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
