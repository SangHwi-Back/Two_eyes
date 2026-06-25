import SwiftUI
import Photos
import Shared

struct ContentView: View {
    @Environment(\.database) var database
    @Environment(\.apiClient) var apiClient
    @Environment(\.userData) var userData

    @State var tabSelection: TabSelection = .feed
    @State private var showLogin = false
    @Environment(\.rootViewController) var rootViewController: UIViewController

    @StateObject var cameraPath = NavigationPathObject(path: [NavHost.Camera]())
    @StateObject var uploadPath = NavigationPathObject(path: [NavHost.Upload]())

    var body: some View {
        TabView(selection: $tabSelection) {

            // MARK: Feed
            Tab("Feed", systemImage: "text.below.photo", value: .feed) {
                NavigationStack {
                    FeedListView(apiClient: apiClient)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { loginToolbarButton }
                }
            }

            // MARK: Camera
            Tab("Camera", systemImage: "camera", value: .camera) {
                NavigationStack(path: $cameraPath.path) {
                    PickImageView()
                        .navigationDestination(for: NavHost.Camera.self) { route in
                            switch route {
                            case .main:
                                PickImageView()
                            case .merge(let leading, let trailing):
                                PickImageMergeView(model: .init(leading: leading, trailing: trailing))
                            }
                        }
                }
                .environmentObject(cameraPath)
            }
            Tab("Upload", systemImage: "square.and.arrow.up", value: .upload) {
                NavigationStack(path: $uploadPath.path) {
                    UploadView(database: database, client: apiClient)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { loginToolbarButton }
                        .navigationDestination(for: NavHost.Upload.self) { route in
                            switch route {
                            case .main(let database):
                                UploadView(
                                    database: database,
                                    client: apiClient
                                )
                            case .upload(let entity, let vm):
                                UploadCreateFeedView(entity: entity, vm: vm)
                            }
                        }
                }
                .environmentObject(uploadPath)
            }
        }
        .task {
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
        // 로그인 바텀 시트 — 화면 절반 높이로 아래에서 올라옴
        .sheet(isPresented: $showLogin) {
            LoginView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - 로그인/프로필 툴바 버튼
    // 미로그인: person.circle (아웃라인) → 탭 시 LoginView 표시
    // 로그인 됨: person.circle.fill (채움)  → 추후 프로필 화면으로 연결
    @ToolbarContentBuilder
    private var loginToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showLogin = true
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
    case feed, camera, upload
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
