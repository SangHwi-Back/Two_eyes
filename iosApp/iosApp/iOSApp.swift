import SwiftUI
import Shared

@main
struct iOSApp: App {
    let database = Database_iosKt.getAppDatabase()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.database, database)
                .environment(\.mergeResultDao, database.getMergeResultDao())
        }
    }
}
