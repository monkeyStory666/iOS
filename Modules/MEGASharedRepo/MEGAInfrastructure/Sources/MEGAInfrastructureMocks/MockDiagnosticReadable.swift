// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure

public class MockDiagnosticReadable: DiagnosticReadable {
    public func identifier() async -> String {
        "identifier"
    }

    public func readableDiagnostic() async -> String {
        "complete diagnostic"
    }
    
    public init() {}
}
