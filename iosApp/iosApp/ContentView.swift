import SwiftUI
import Shared

struct ContentView: View {
    @State private var showContent = false
    
    @State var tabSelection: TabSelection = .feed
    @State var feedPath = NavigationPathObject(path: [NavHost.Feed]())
    @StateObject var cameraPath = NavigationPathObject(path: [NavHost.Camera]())
    @State var uploadPath = NavigationPathObject(path: [NavHost.Upload]())
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Feed", systemImage: "text.below.photo", value: .feed) {
                NavigationStack(path: $feedPath.path) {
                    FeedListView()
                }
                .environmentObject(feedPath)
            }
            Tab("Camera", systemImage: "camera", value: .camera) {
                NavigationStack(path: $cameraPath.path) {
                    PickImageView()
                }
                .environmentObject(cameraPath)
                .navigationDestination(for: NavHost.Camera.self) { route in
                    switch route {
                    case .main:
                        PickImageView()
                    case .merge(let leadingImage, let trailingImage):
                        PickImageMergeView(
                            leadingImage: leadingImage,
                            trailingImage: trailingImage
                        )
                    }
                }
            }
            Tab("Upload", systemImage: "square.and.arrow.up", value: .upload) {
                NavigationStack(path: $uploadPath.path) {
                    UploadView()
                }
                .environmentObject(uploadPath)
            }
        }
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
        case merge(UIImage, UIImage)
    }
    
    enum Upload: Hashable {
        case main
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
    
    @MainActor func push(to type: T) {
        self.path.append(type)
    }
    
    @MainActor func pop() {
        self.path.removeLast()
    }
    
    @MainActor func popToRoot() {
        self.path.removeAll()
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
