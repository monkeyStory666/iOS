// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

final class LoggerDelegate: NSObject, MEGALoggerDelegate {
    typealias LogHandler = (LogInformation) -> Void

    private let logHandler: LogHandler

    init(logHandler: @escaping LogHandler) {
        self.logHandler = logHandler
    }

    func log(withTime time: String, logLevel: MEGALogLevel, source: String, message: String) {
        let logInformation = LogInformation(time: time, level: logLevel.toLogLevel(), source: source, message: message)
        logHandler(logInformation)
    }
}
