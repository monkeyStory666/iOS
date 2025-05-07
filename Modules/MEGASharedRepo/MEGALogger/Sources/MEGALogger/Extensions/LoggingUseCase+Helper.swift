// Copyright © 2025 MEGA Limited. All rights reserved.

public extension LoggingUseCaseProtocol {
    func log(
        with logLevel: LogLevel,
        message: String,
        filename: String = #file,
        line: Int = #line
    ) {
        log(
            with: logLevel,
            message: message,
            filename: filename,
            line: line
        )
    }

    func logError<R>(
        message: String,
        filename: String = #file,
        line: Int = #line,
        throwingAction: () throws -> R
    ) rethrows -> R {
        do {
            return try throwingAction()
        } catch {
            log(
                with: .error,
                message: "\(message) (\(error.localizedDescription))",
                filename: filename, line: line
            )
            throw error
        }
    }

    func logError<R>(
        message: String,
        filename: String = #file,
        line: Int = #line,
        throwingAction: () async throws -> R
    ) async rethrows -> R {
        do {
            return try await throwingAction()
        } catch {
            log(
                with: .error,
                message: "\(message) (\(error.localizedDescription))",
                filename: filename, line: line
            )
            throw error
        }
    }
}
