//
//  ComponentHolder.swift
//  iosApp
//
//  Created by 백상휘 on 10/18/26.
//

import Combine
import Shared

class ComponentHolder: ObservableObject {
    let component: TwoEyesRootComponent
    @Published var overlayView: OverlayView = .none
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let context = DefaultComponentContext(lifecycle: ApplicationLifecycle())
        component = TwoEyesRootComponent(componentContext: context)
        
        objectWillChange.sink { [weak self] _ in
            let overlay = self?.component.overlayComponent.slot.value.child?.instance
            switch overlay {
            case is OverlayComponentOverlaySlotLogin:
                self?.overlayView = .login
            default:
                self?.overlayView = .none
            }
        }
        .store(in: &cancellables)
    }
    
    func showLogin() {
        component.overlayComponent.showLogin()
    }
}
