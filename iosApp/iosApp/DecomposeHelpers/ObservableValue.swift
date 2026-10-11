import SwiftUI
import Shared
import Combine

public class ObservableValue<T: AnyObject>: ObservableObject {
    @Published
    var value: T

    private var cancellation: AnyCancellable?

    init(_ value: Value<T>) {
        self.value = value.value
        self.cancellation = value
            .subscribe { [weak self] value in self?.value = value }
            .asCancellable()
    }

    deinit {
        cancellation?.cancel()
    }
}
