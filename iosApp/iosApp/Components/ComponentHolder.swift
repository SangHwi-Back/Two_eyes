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
    
    @Published var currentTab: TabSelection
    @Published var overlayView: OverlayView = .none
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(tab: TabSelection) {
        let context = DefaultComponentContext(lifecycle: ApplicationLifecycle())
        component = TwoEyesRootComponent(componentContext: context)
        currentTab = tab
        
        objectWillChange.sink { [weak self] _ in
            guard let self else { return }
            let overlay = self.component.overlayComponent.slot.value.child?.instance
            let newView: OverlayView = (overlay is OverlayComponentOverlaySlotLogin) ? .login : .none
            guard self.overlayView != newView else { return }  // ← 같으면 할당 안 함
            self.overlayView = newView
        }
        .store(in: &cancellables)
    }
    
    func showLogin() {
        component.overlayComponent.showLogin()
    }
}
