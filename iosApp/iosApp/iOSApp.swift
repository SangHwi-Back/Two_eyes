import SwiftUI
import shared
import GoogleSignIn

enum TwoEyesUserData {
    case apple(AppleUserData)
    case google(GoogleUserData)
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
                .onOpenURL(perform:{ url in
                    GIDSignIn.sharedInstance.handle(url)
                })
                .task {
                    if let userData = try? KeychainModel<AppleUserData>().readItem() {
                        self.userData = .apple(userData)
                    }
                    else if let userData = try? KeychainModel<GoogleUserData>().readItem() {
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
