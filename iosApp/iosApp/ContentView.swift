import SwiftUI
import Shared

struct ContentView: View {
    @State private var showContent = false
    
    @State var tabSelection: TabSelection = .feed
    @State var feedPath: [NavHost.Feed] = []
    @State var cameraPath: [NavHost.Camera] = []
    @State var uploadPath: [NavHost.Upload] = []
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Feed", systemImage: "text.below.photo", value: .feed) {
                NavigationStack(path: $feedPath) {
                    FeedListView()
                }
            }
            Tab("Camera", systemImage: "camera", value: .camera) {
                NavigationStack(path: $cameraPath) {
                    PickImageView()
                }
            }
            Tab("Upload", systemImage: "square.and.arrow.up", value: .upload) {
                NavigationStack(path: $uploadPath) {
                    UploadView()
                }
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
        case merge
    }
    
    enum Upload: Hashable {
        case main
    }
}

enum TabSelection: Hashable {
    case feed, camera, upload
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
