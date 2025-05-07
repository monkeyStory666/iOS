// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAInfrastructure
import MEGATest

public final class MockCopyToClipboard: MockObject<MockCopyToClipboard.Action>, CopyToClipboardProtocol {
    public enum Action: Equatable {
        case copy(String)
    }

    public func copy(text: String) {
        actions.append(.copy(text))
    }
}
