// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASwift

public protocol DiagnosticReadable: Sendable {
    func readableDiagnostic() async -> String
}

public struct DiagnosticReadableCollection: DiagnosticReadable, Sendable {
    private let diagnosticReadables: [any DiagnosticReadable]

    public init(diagnosticReadables: [any DiagnosticReadable]) {
        self.diagnosticReadables = diagnosticReadables
    }

    public func readableDiagnostic() async -> String {
        await diagnosticReadables
            .asyncMap { await $0.readableDiagnostic() }
            .map { "\n\n" + $0 }
            .joined()
    }
}
