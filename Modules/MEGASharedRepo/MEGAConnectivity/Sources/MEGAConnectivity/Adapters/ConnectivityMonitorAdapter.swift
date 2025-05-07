// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Foundation

public final class ConnectivityMonitorAdapter: ConnectionMonitorProtocol {
    static let checkInternetInterval: TimeInterval = 3
    public static var shared = ConnectivityMonitorAdapter()

    public var isConnected: Bool { isConnectedSubject.value }
    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    private var isMonitoring = false

    private var isConnectedSubject = CurrentValueSubject<Bool, Never>(true)
    private var checkConnectionTimer: Timer?
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Self.checkInternetInterval
        configuration.timeoutIntervalForResource = Self.checkInternetInterval
        return URLSession(configuration: configuration)
    }()

    deinit {
        stopMonitoring()
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }

        checkConnectionTimer?.invalidate()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let timer = Timer.scheduledTimer(
                timeInterval: Self.checkInternetInterval,
                target: self,
                selector: #selector(checkInternetConnectivity),
                userInfo: nil,
                repeats: true
            )
            checkConnectionTimer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
        isMonitoring = true
    }

    public func stopMonitoring() {
        guard !isMonitoring else { return }

        checkConnectionTimer?.invalidate()
        checkConnectionTimer = nil
        isMonitoring = false
    }

    private let megaURL = URL(string: "https://www.mega.io")!
    private let fallbackURL = URL(string: "https://www.google.com")!

    @objc
    private func checkInternetConnectivity() {
        Task { [weak self] in
            guard let self else { return }

            guard await !isConnectedToURL(megaURL) else {
                return isConnectedSubject.send(true)
            }

            guard await !isConnectedToURL(fallbackURL) else {
                return isConnectedSubject.send(true)
            }

            return isConnectedSubject.send(false)
        }
    }

    private func isConnectedToURL(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await urlSession.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
