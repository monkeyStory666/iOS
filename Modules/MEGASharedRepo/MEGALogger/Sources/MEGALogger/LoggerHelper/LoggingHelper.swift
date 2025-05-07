// Copyright © 2023 MEGA Limited. All rights reserved.

import CocoaLumberjackSwift
import Foundation
import MEGASdk

final class LoggingHelper: NSObject {
    private let fileLogger: DDFileLogger

    private var logsDirectoryUrl: URL {
        URL(fileURLWithPath: fileLogger.logFileManager.logsDirectory)
    }

    nonisolated(unsafe) static var shared = LoggingHelper()

    override private init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let documentDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folderURL = documentDirectory.appendingPathComponent("\(DependencyInjection.clientAppName)/Logs")
        let manager = DDLogFileManagerDefault(logsDirectory: folderURL.path)
        let fileLogger = DDFileLogger(logFileManager: manager)
        fileLogger.rollingFrequency = 0
        fileLogger.logFileManager.maximumNumberOfLogFiles = 20
        fileLogger.maximumFileSize = 10 * 1_024 * 1_024 // 10 MB
        fileLogger.logFileManager.logFilesDiskQuota = 200 * 1_024 * 1_024 // 200 MB
        fileLogger.logFormatter = CustomDDLogFormatter()
        DDLog.add(fileLogger)
        self.fileLogger = fileLogger
        super.init()
    }

    func logFiles() throws -> [URL] {
        var logs = [URL]()

        let files = try FileManager.default.contentsOfDirectory(atPath: logsDirectoryUrl.path)
        logs = files.map { logsDirectoryUrl.appendingPathComponent($0) }

        return logs
    }

    func removeLogsDirectory( _ file: String = #file, _ line: Int = #line) throws {
        try FileManager.default.removeItem(at: logsDirectoryUrl)
    }
}

extension LoggingHelper: MEGALoggerDelegate {
    public func log(
        withTime time: String,
        logLevel: MEGALogLevel,
        source: String,
        message: String
    ) {
        let logMessage = "[\(time)]"
            + "[\(logLevel.toLogLevel().rawValue)]"
            + "[\(source.fileNameAndLineNumber)]"
            + " \(message)"

        switch logLevel {
        case .fatal, .error:
            DDLogError(logMessage.logMessageFormat)
        case .warning:
            DDLogWarn(logMessage.logMessageFormat)
        case .info:
            DDLogInfo(logMessage.logMessageFormat)
        case .debug:
            DDLogDebug(logMessage.logMessageFormat)
        case .max:
            DDLogVerbose(logMessage.logMessageFormat)
        default:
            DDLogVerbose(logMessage.logMessageFormat)
        }
    }
}

private final class CustomDDLogFormatter: NSObject, DDLogFormatter {
    // MARK: - DDLogFormatter
    func format(message logMessage: DDLogMessage) -> String? {
        logMessage.message
    }
}

private extension String {
    var logMessageFormat: DDLogMessageFormat {
        DDLogMessageFormat(stringLiteral: self)
    }

    var fileNameAndLineNumber: String {
        components(separatedBy: "/").last ?? ""
    }
}
