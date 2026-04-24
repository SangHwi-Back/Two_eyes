import SwiftUI
import Shared

@main
struct iOSApp: App {
    let apiClient = ApiClient()
    let database = Database_iosKt.getAppDatabase()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.database, database)
                .environment(\.mergeResultDao, database.getMergeResultDao())
                .environment(\.apiClient, apiClient)
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
}
