// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAConnectivity
import MEGATest

public final class MockConnectionMonitor: MockObject<MockConnectionMonitor.Action>, ConnectionMonitorProtocol {
    public enum Action: Equatable {
        case startMonitoring
        case stopMonitoring
    }

    public var isConnected: Bool { isConnectedSubject.value }
    public var isConnectedPublisher: AnyPublisher<Bool, Never> { isConnectedSubject.eraseToAnyPublisher() }

    private var isConnectedSubject: CurrentValueSubject<Bool, Never>

    public init(isConnected: Bool = true) {
        self.isConnectedSubject = CurrentValueSubject(isConnected)
    }

    public func simulate(isConnected: Bool) {
        isConnectedSubject.send(isConnected)
    }

    public func startMonitoring() {
        actions.append(.startMonitoring)
    }

    public func stopMonitoring() {
        actions.append(.stopMonitoring)
    }
}
