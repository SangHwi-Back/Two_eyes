import SwiftUI
import Shared

enum TwoEyesUserData {
    case apple(SecureUserData.AppleUserData)
    case google(SecureUserData.GoogleUserData)
}

@main
struct iOSApp: App {
    let apiClient = ApiClient()
    let database = Database_iosKt.getAppDatabase()
    
    @State var userData: TwoEyesUserData? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.database, database)
                .environment(\.mergeResultDao, database.getMergeResultDao())
                .environment(\.apiClient, apiClient)
                .environment(\.userData, $userData)
                .task {
                    let storage = PlatformSecureStorage()
                    
                    if let userData = storage.getObject(key: "AppleUserData") as? SecureUserData.AppleUserData {
                        self.userData = .apple(userData)
                    }
                    else if let userData = storage.getObject(key: "GoogleUserData") as? SecureUserData.GoogleUserData {
                        self.userData = .google(userData)
                    }
                }
        }
    }
}

extension EnvironmentValues {
    @Entry var database = Database_iosKt.getAppDatabase()
    @Entry var mergeResultDao = Database_iosKt.getAppDatabase().getMergeResultDao()
    @Entry var apiClient = ApiClient()
    @Entry var feedPath = "FeedPath"
    @Entry var cameraPath = [NavHost.Camera]()
    @Entry var uploadPath = [NavHost.Upload]()
    @Entry var userData: Binding<TwoEyesUserData?> = .constant(nil)
}
