// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Foundation

public protocol LoggingUseCaseProtocol {
    func logFiles() throws -> [URL]
    func log(with logLevel: LogLevel, message: String, filename: String, line: Int)
    func prepareForLogging()
}

public final class LoggingUseCase: LoggingUseCaseProtocol {
    private var hasSetupRepository = false
    private var isLoggingEnabled = false
    private var observeDebugModeCancellable: AnyCancellable?

    private let repository: any LoggingRepositoryProtocol
    private let isDebugModePublisher: AnyPublisher<Bool, Never>

    public init(
        repository: some LoggingRepositoryProtocol,
        isDebugModePublisher: AnyPublisher<Bool, Never>
    ) {
        self.repository = repository
        self.isDebugModePublisher = isDebugModePublisher
    }

    public func logFiles() throws -> [URL] {
        try repository.logFiles()
    }

    public func log(
        with logLevel: LogLevel,
        message: String,
        filename: String,
        line: Int
    ) {
        repository.log(
            with: logLevel,
            message: message,
            filename: filename,
            line: line
        )
    }

    public func prepareForLogging() {
        setupRepository()
        observeDebugMode()
    }

    private func setupRepository() {
        guard !hasSetupRepository else { return }

        repository.set(logLevel: .max)
    }

    private func observeDebugMode() {
        observeDebugModeCancellable = isDebugModePublisher.sink { [weak self] isDebugMode in
            self?.debugModeChanged(isDebugMode)
        }
    }

    private func debugModeChanged(_ isDebugMode: Bool) {
        if isLoggingEnabled != isDebugMode {
            isLoggingEnabled = isDebugMode
            repository.toggleLogging(isDebugMode)
        }

        if !isDebugMode {
            try? repository.removeLogs()
        }
    }
}
