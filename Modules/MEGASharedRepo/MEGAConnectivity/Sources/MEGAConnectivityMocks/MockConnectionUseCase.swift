// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAConnectivity

public final class MockConnectionUseCase: ConnectionUseCaseProtocol {
    // MARK: - isConnected

    private var isConnectedSubject: CurrentValueSubject<Bool, Never>

    public var isConnected: Bool { isConnectedSubject.value }
    public var isConnectedPublisher: AnyPublisher<Bool, Never> { isConnectedSubject.eraseToAnyPublisher() }
    public var isNetworkConnected: Bool { isConnectedSubject.value }

    // MARK: - Connectivity Status

    private var connectivityStatusSubject: CurrentValueSubject<ConnectivityStatus, Never>

    public var connectivityStatus: ConnectivityStatus {
        connectivityStatusSubject.value
    }
    public var connectivityStatusPublisher: AnyPublisher<ConnectivityStatus, Never> {
        connectivityStatusSubject.eraseToAnyPublisher()
    }

    public init(
        isConnected: Bool = true,
        connectivityStatus: ConnectivityStatus = .connectedToInternet
    ) {
        self.isConnectedSubject = .init(isConnected)
        self.connectivityStatusSubject = .init(connectivityStatus)
    }

    public func simulateConnection(isConnected: Bool) {
        isConnectedSubject.send(isConnected)
    }

    public func simulateStatus(_ connectivityStatus: ConnectivityStatus) {
        connectivityStatusSubject.send(connectivityStatus)
    }
}
