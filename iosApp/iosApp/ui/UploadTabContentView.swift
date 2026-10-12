//
//  UploadTabContentView.swift
//  iosApp
//
//  Created by 백상휘 on 10/10/26.
//
import SwiftUI
import Shared

struct UploadTabContentView: View {
    @Environment(\.database) var database
    @Environment(\.apiClient) var apiClient
    
    let component: UploadTabComponent
    let uploadableListComponent: UploadableListViewComponent
    
    @StateValue var stack: ChildStack<AnyObject, any UploadTabComponentChild>
    
    init(component: UploadTabComponent) {
        self.component = component
        let stackValue = StateValue(component.stack)
        _stack = stackValue
        
        let uploadItems = component.stack.value.items.compactMap {
            $0.instance as? UploadTabComponentChildUploadableListView
        }
        
        guard let uploadableListComponent = uploadItems.first?.component else {
            fatalError()
        }
        
        self.uploadableListComponent = uploadableListComponent
    }
    
    private var pathBinding: Binding<[UploadTabPathElement]> {
        Binding {
            stack.items.dropFirst().enumerated().compactMap { index, item in
                switch item.instance {
                case let c as UploadTabComponentChildUploadView:
                    return .upload(id: index, component: c.component)
                default:
                    return nil
                }
            }
        } set: { newPath in
            let popCount = self.pathBinding.wrappedValue.count - newPath.count
            if popCount > 0 {
                for _ in 0..<popCount {
                    if let elem = component as? TabComponentElement {
                        TabComponentElementKt.onBackClicked(elem)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: pathBinding) {
            UploadView(
                component: uploadableListComponent,
                wrapper: UploadViewModelWrapper(
                db: database,
                client: apiClient
            )).navigationDestination(for: UploadTabPathElement.self) { element in
                    switch element {
                    case .upload(_, let component):
                        UploadCreateFeedView(
                            component: component,
                            wrapper: UploadViewModelWrapper(
                                db: database,
                                client: apiClient
                            )
                        )
                    }
                }
        }
    }
}

enum UploadTabPathElement: Hashable {
    case upload(id: Int, component: UploadViewComponent)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.upload(l, _), .upload(r, _)):
            return l == r
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .upload(let id, _):
            hasher.combine(id)
            hasher.combine(0)
        }
    }
}
