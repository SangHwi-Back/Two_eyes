import SwiftUI
import Shared

struct ContentView: View {
    @State private var showContent = false
    
    @State var path: [FeedItemModel] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            FeedListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
