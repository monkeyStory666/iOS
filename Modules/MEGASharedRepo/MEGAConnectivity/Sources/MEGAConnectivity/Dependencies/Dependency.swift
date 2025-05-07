// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum DependencyInjection {
    public static var singletonConnectionUseCase: some ConnectionUseCaseProtocol = {
        ConnectionUseCase(
            networkConnectionMonitor: singletonNetworkMonitor,
            internetConnectionMonitor: singletonConnectivityMonitor
        )
    }()

    public static var noInternetViewModel: NoInternetViewModel {
        NoInternetViewModel(connectionUseCase: singletonConnectionUseCase)
    }

    public static var singletonNetworkMonitor: some ConnectionMonitorProtocol {
        NetworkMonitorAdapter.shared
    }

    public static var singletonConnectivityMonitor: some ConnectivityMonitorAdapter {
        ConnectivityMonitorAdapter.shared
    }
}

public extension NoInternetViewModel {
    convenience init(connectionUseCase: some ConnectionUseCaseProtocol) {
        self.init(
            connectionUseCase: connectionUseCase,
            runOnMainThread: { DispatchQueue.main.async(execute: $0) },
            delayedCaller: { DispatchQueue.main.asyncAfter(deadline: .now() + $0, execute: $1) }
        )
    }
}
