//
//  PickImageTabContentView.swift
//  iosApp
//
//  Created by 백상휘 on 10/10/26.
//
import SwiftUI
import Shared

struct PickImageTabContentView: View {
    let component: PickImageTabComponent
    let pickImageComponent: DevicePickImageViewComponent
    
    @StateValue var stack: ChildStack<AnyObject, any PickImageTabComponentChild>
    
    init(component: PickImageTabComponent) {
        self.component = component
        let stackValue = StateValue(component.stack)
        _stack = stackValue
        
        let pickImageItems = component.stack.value.items.compactMap {
            $0.instance as? PickImageTabComponentChildDevicePickImageView
        }
        
        guard let pickImageComponent = pickImageItems.first?.component else {
            fatalError()
        }
        
        self.pickImageComponent = pickImageComponent
    }
    
    private var pathBinding: Binding<[PickImageTabPathElement]> {
        Binding {
            stack.items.dropFirst().enumerated().compactMap { index, item in
                switch item.instance {
                case let c as PickImageTabComponentChildMergeImageView:
                    return .merge(id: index, component: c.component)
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
            PickDeviceImageContentView(component: pickImageComponent)
                .navigationDestination(for: PickImageTabPathElement.self) { element in
                    switch element {
                    case .merge(_, let component):
                        PickImageMergeContentView(component: component)
                    }
                }
        }
    }
}

enum PickImageTabPathElement: Hashable {
    case merge(id: Int, component: MergeImageViewComponent)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.merge(l, _), .merge(r, _)):
            return l == r
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .merge(let id, _):
            hasher.combine(0)
            hasher.combine(id)
        }
    }
}
