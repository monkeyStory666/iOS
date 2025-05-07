// Copyright © 2025 MEGA Limited. All rights reserved.

public func MEGALogFatal(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .fatal,
        message: message,
        filename: file,
        line: line
    )
}

public func MEGALogError(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .error,
        message: message,
        filename: file,
        line: line
    )
}

public func MEGALogWarning(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .warning,
        message: message,
        filename: file,
        line: line
    )
}

public func MEGALogInfo(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .info,
        message: message,
        filename: file,
        line: line
    )
}

public func MEGALogDebug(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .debug,
        message: message,
        filename: file,
        line: line
    )
}

public func MEGALogMax(
    _ message: String,
    _ file: String = #file,
    _ line: Int = #line
) {
    DependencyInjection.loggingUseCase.log(
        with: .max,
        message: message,
        filename: file,
        line: line
    )
}
