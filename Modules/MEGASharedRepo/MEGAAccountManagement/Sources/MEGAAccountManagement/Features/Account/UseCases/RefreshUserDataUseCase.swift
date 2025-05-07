import Combine

public protocol RefreshUserDataNotificationUseCaseProtocol {
    func notify()
    func observe() -> AnyPublisher<Void, Never>
}

public class RefreshUserDataUseCase: RefreshUserDataNotificationUseCaseProtocol {
    private var observer = PassthroughSubject<Void, Never>()

    public init() {}
    public func notify() {
        observer.send()
    }

    public func observe() -> AnyPublisher<Void, Never> {
        observer.eraseToAnyPublisher()
    }
}
