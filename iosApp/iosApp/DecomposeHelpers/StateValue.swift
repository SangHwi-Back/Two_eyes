import SwiftUI
import Shared

@propertyWrapper struct StateValue<T: AnyObject>: DynamicProperty {
    @ObservedObject
    private var obj: ObservableValue<T>

    var wrappedValue: T {
        get { obj.value }
        nonmutating set { obj.value = newValue }
    }
    
    // 2. projectedValue를 Binding<T>로 정의 ($를 붙여 접근)
    var projectedValue: Binding<T> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    

    init(_ value: Value<T>) {
        obj = ObservableValue(value)
    }
}
