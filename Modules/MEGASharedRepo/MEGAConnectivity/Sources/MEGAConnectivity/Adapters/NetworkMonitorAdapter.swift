// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Foundation
import Network

public final class NetworkMonitorAdapter: ConnectionMonitorProtocol {
    public static var shared = NetworkMonitorAdapter()

    public var isConnected: Bool {
        // Simulator always return no network, so I add this to help ease testing with simulators
        #if targetEnvironment(simulator)
        return true
        #else
        return monitor.currentPath.status == .satisfied
        #endif
    }

    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private var isMonitoring = false

    private let monitor = NWPathMonitor()
    private var isConnectedSubject = CurrentValueSubject<Bool, Never>(true)

    private init() {}

    deinit {
        stopMonitoring()
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }

        #if targetEnvironment(simulator)
        // Simulator always return no network, so I add this to help ease testing with simulators
        isConnectedSubject.send(true)
        #else
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            if path.status == .satisfied {
                isConnectedSubject.send(true)
            } else {
                isConnectedSubject.send(false)
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        #endif
        isMonitoring = true
    }

    public func stopMonitoring() {
        guard isMonitoring else { return }

        monitor.cancel()
        isMonitoring = false
    }
}
