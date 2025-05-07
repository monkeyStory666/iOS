// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine

public protocol ConnectionMonitorProtocol {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }

    func startMonitoring()
    func stopMonitoring()
}
