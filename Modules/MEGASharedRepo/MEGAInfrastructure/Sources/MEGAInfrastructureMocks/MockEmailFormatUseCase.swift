// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGATest

public final class MockEmailFormatUseCase: MockObject<MockEmailFormatUseCase.Action>, EmailFormatUseCaseProtocol {
    public enum Action: Equatable {
        case createEmailFormat
    }

    public var _createEmailFormat: EmailEntity

    public init(createEmailFormat: EmailEntity = .dummy()) {
        self._createEmailFormat = createEmailFormat
    }

    public func createEmailFormat() async -> EmailEntity {
        actions.append(.createEmailFormat)
        return _createEmailFormat
    }
}
