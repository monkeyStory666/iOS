// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine

/// `ConnectionUseCaseProtocol` provides an interface to check network and internet connection status,
/// and to observe changes in connectivity status. It distinguishes between being connected to a network
/// (e.g., WiFi or cellular) and having actual internet access.
public protocol ConnectionUseCaseProtocol {
    /// A boolean value indicating whether the device is connected to the internet.
    /// Use this property to quickly check for internet connectivity before performing network requests.
    var isConnected: Bool { get }

    /// A boolean value indicating whether the device is connected to a network.
    /// This property can be true even if the internet is not reachable. Useful for differentiating
    /// between no network and a network without internet access.
    var isNetworkConnected: Bool { get }

    /// A publisher that emits a boolean value representing the internet connection status.
    /// Subscribe to this publisher to reactively handle changes in internet connectivity within your application.
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }

    /// The current `ConnectivityStatus` of the user device.
    /// It provides a snapshot of whether the device is disconnected, connected without internet,
    /// or connected with internet access.
    var connectivityStatus: ConnectivityStatus { get }

    /// A publisher that emits `ConnectivityStatus` values, providing detailed information about the current
    /// connectivity status, including no connection, connected to a network without internet, and connected to the internet.
    /// This allows for fine-grained control over application behavior based on the specific connectivity state.
    var connectivityStatusPublisher: AnyPublisher<ConnectivityStatus, Never> { get }
}

public enum ConnectivityStatus {
    case disconnected
    case connectedWithoutInternet
    case connectedToInternet
}

public final class ConnectionUseCase: ConnectionUseCaseProtocol {
    public var isConnected: Bool {
        connectivityStatusSubject.value == .connectedToInternet
    }

    public var isNetworkConnected: Bool {
        networkConnectionMonitor.isConnected
    }

    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        connectivityStatusSubject
            .map { $0 == .connectedToInternet }
            .eraseToAnyPublisher()
    }

    public var connectivityStatus: ConnectivityStatus {
        connectivityStatusSubject.value
    }

    public var connectivityStatusPublisher: AnyPublisher<ConnectivityStatus, Never> {
        connectivityStatusSubject.eraseToAnyPublisher()
    }

    private var connectivityStatusSubject = CurrentValueSubject<ConnectivityStatus, Never>(.connectedToInternet)

    private var networkMonitoringCancellable: AnyCancellable?
    private var connectivityMonitoringCancellable: AnyCancellable?

    private let networkConnectionMonitor: any ConnectionMonitorProtocol
    private let internetConnectionMonitor: any ConnectionMonitorProtocol

    public init(
        networkConnectionMonitor: some ConnectionMonitorProtocol,
        internetConnectionMonitor: some ConnectionMonitorProtocol
    ) {
        self.networkConnectionMonitor = networkConnectionMonitor
        self.internetConnectionMonitor = internetConnectionMonitor
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        networkConnectionMonitor.startMonitoring()
        networkMonitoringCancellable?.cancel()
        networkMonitoringCancellable = networkConnectionMonitor
            .isConnectedPublisher
            .sink { [weak self] isConnectedToNetwork in
                if isConnectedToNetwork {
                    self?.startMonitoringInternetConnection()
                } else {
                    self?.stopMonitoringInternetConnection()
                    self?.connectivityStatusSubject.send(.disconnected)
                }
            }
    }

    private func stopMonitoring() {
        networkConnectionMonitor.stopMonitoring()
        networkMonitoringCancellable?.cancel()
        stopMonitoringInternetConnection()
    }

    private func startMonitoringInternetConnection() {
        internetConnectionMonitor.startMonitoring()

        connectivityMonitoringCancellable?.cancel()
        connectivityMonitoringCancellable = internetConnectionMonitor
            .isConnectedPublisher.sink { [weak self] isConnectedToInternet in
                self?.connectivityStatusSubject
                    .send(
                        isConnectedToInternet
                            ? .connectedToInternet
                            : .connectedWithoutInternet
                    )
            }
    }

    private func stopMonitoringInternetConnection() {
        internetConnectionMonitor.stopMonitoring()
        connectivityMonitoringCancellable?.cancel()
    }
}
