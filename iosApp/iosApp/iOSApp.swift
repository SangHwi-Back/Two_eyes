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
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}

extension EnvironmentValues {
    @Entry var database = Database_iosKt.getAppDatabase()
    @Entry var mergeResultDao = Database_iosKt.getAppDatabase().getMergeResultDao()
    @Entry var apiClient = ApiClient()
    @Entry var userData: Binding<TwoEyesUserData?> = .constant(nil)
    @Entry var appConstant = AppConstants()
    @Entry var rootViewController = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController)!
}
