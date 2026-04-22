import SwiftUI
import Photos
import Shared

struct ContentView: View {
    @Environment(\.database) var database
    @State private var showContent = false
    
    @State var tabSelection: TabSelection = .feed
    @State var feedPath = NavigationPathObject(path: [NavHost.Feed]())
    @StateObject var cameraPath = NavigationPathObject(path: [NavHost.Camera]())
    @State var uploadPath = NavigationPathObject(path: [NavHost.Upload]())
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Feed", systemImage: "text.below.photo", value: .feed) {
                NavigationStack(path: $feedPath.path) {
                    FeedListView().navigationDestination(for: NavHost.Feed.self) { route in
                        switch route {
                        case .main:
                            FeedListView()
                        case .feedDetail(let model):
                            FeedItemView(model: model)
                        }
                    }
                }
                .environmentObject(feedPath)
            }
            Tab("Camera", systemImage: "camera", value: .camera) {
                NavigationStack(path: $cameraPath.path) {
                    PickImageView().navigationDestination(for: NavHost.Camera.self) { route in
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
                    UploadView(database: database).navigationDestination(for: NavHost.Upload.self) { route in
                        switch route {
                        case .main(let database):
                            UploadView(database: database)
                        }
                    }
                }
                .environmentObject(uploadPath)
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var database = Database_iosKt.getAppDatabase()
    @Entry var mergeResultDao = Database_iosKt.getAppDatabase().getMergeResultDao()
}

// Kotlin/Native 가 object 에 대해 .shared 를 자동 생성하므로 별도 extension 불필요

extension Int64 {
    // Kotlin ARGB Long (0xFFRRGGBBL) → SwiftUI Color
    var color: Color {
        let argb = UInt32(self & 0xFFFFFFFF)
        let alpha = Double((argb >> 24) & 0xFF) / 255.0
        let red   = Double((argb >> 16) & 0xFF) / 255.0
        let green = Double((argb >> 8)  & 0xFF) / 255.0
        let blue  = Double(argb         & 0xFF) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

enum NavHost {
    case feed(Feed)
    case camera(Camera)
    case upload(Upload)
    
    enum Feed: Hashable {
        case main
        case feedDetail(FeedItemModel)
    }
    
    enum Camera: Hashable {
        case main
        case merge(PHAsset, PHAsset)
    }
    
    enum Upload: Hashable {
        case main(AppDatabase)
    }
}

enum TabSelection: Hashable {
    case feed, camera, upload
}

extension EnvironmentValues {
    @Entry var feedPath = "FeedPath"
    @Entry var cameraPath = [NavHost.Camera]()
    @Entry var uploadPath = "UploadPath"
}

extension View {
    func cameraPath(_ path: [NavHost.Camera]) -> some View {
        environment(\.cameraPath, path)
    }
}

class NavigationPathObject<T: Hashable>: ObservableObject {
    @Published var path: [T]
    
    /// popToRoot() 호출 시 실행할 콜백.
    /// 루트 뷰의 onAppear 에서 등록해 두면 onChange 없이 상태를 초기화할 수 있습니다.
    var onPopToRoot: (() -> Void)?
    
    @MainActor func push(to type: T) {
        self.path.append(type)
    }
    
    @MainActor func pop() {
        self.path.removeLast()
    }
    
    @MainActor func popToRoot() {
        self.path.removeAll()
        onPopToRoot?()
    }
    
    init(path: [T]) {
        self.path = path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
