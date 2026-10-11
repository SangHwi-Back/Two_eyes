import Combine
import Shared

extension Cancellation {
    func asCancellable() -> AnyCancellable {
        AnyCancellable { self.cancel() }
    }
}
