import SwiftUI
import Shared

enum TwoEyesUserData {
    case apple(SecureUserData.AppleUserData)
    case google(SecureUserData.GoogleUserData)
}

class RefreshTrigger: ObservableObject {
    @Published var token = UUID()
    func refresh() { token = UUID() }
}

// AppErrorBus(Kotlin) → SwiftUI 알럿 브릿지
class ErrorBusObserver: ObservableObject, AppErrorCallback {
    @Published var currentError: UserFacingError? = nil
    
    init() {
        AppErrorBus.shared.callback = self
    }
    
    func onError(error: UserFacingError) {
        DispatchQueue.main.async {
            self.currentError = error
        }
    }
    
    func clear() {
        currentError = nil
        AppErrorBus.shared.clear()
    }
}

@main
struct iOSApp: App {
    let apiClient = ApiClient()
    let database = Database_iosKt.getAppDatabase()
    
    @StateObject private var refreshTrigger = RefreshTrigger()
    @StateObject private var errorObserver = ErrorBusObserver()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(refreshTrigger.token)
                .environmentObject(refreshTrigger)
                .alert(
                    errorObserver.currentError?.title ?? "",
                    isPresented: Binding(
                        get: { errorObserver.currentError != nil },
                        set: { if !$0 { errorObserver.clear() } }
                    )
                ) {
                    Button("확인") { errorObserver.clear() }
                } message: {
                    Text(errorObserver.currentError?.message ?? "")
                }
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
    @Entry var applyNavigationBarAppearance: () -> Void = {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes      = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    @Entry var resetNavigationBarAppearance: () -> Void = {
        let appearance = UINavigationBarAppearance()
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
