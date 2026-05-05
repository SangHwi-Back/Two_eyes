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
                    if let appleData = storage.getAppleUserData() {
                        self.userData = .apple(appleData)
                    } else if let googleData = storage.getGoogleUserData() {
                        self.userData = .google(googleData)
                    }
                }
        }
    }
}

extension EnvironmentValues {
    @Entry var database = Database_iosKt.getAppDatabase()
    @Entry var mergeResultDao = Database_iosKt.getAppDatabase().getMergeResultDao()
    @Entry var apiClient = ApiClient()
    @Entry var cameraPath = [NavHost.Camera]()
    @Entry var uploadPath = [NavHost.Upload]()
    @Entry var userData: Binding<TwoEyesUserData?> = .constant(nil)
}
