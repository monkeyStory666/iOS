// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import Testing

struct DiagnosticReadableCollectionTests {
    @Test func readableDiagnostic_shouldReturnAllDiagnosticReadable() async {
        let sut = DiagnosticReadableCollection(
            diagnosticReadables: [
                MockDiagnosticReadable(string: "first"),
                MockDiagnosticReadable(string: "second"),
                MockDiagnosticReadable(string: "third")
            ]
        )

        let result = await sut.readableDiagnostic()

        #expect(result == "\n\nfirst\n\nsecond\n\nthird")
    }

    // MARK: - Test Helpers

    private struct MockDiagnosticReadable: DiagnosticReadable {
        let string: String

        init(string: String = .random()) {
            self.string = string
        }

        func readableDiagnostic() async -> String {
            string
        }
    }
}
