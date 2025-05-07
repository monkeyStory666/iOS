// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockChangeNameUseCase:
    MockObject<MockChangeNameUseCase.Action>,
    ChangeNameUseCaseProtocol {
    public enum Action: Equatable {
        case changeName(firstName: String, lastName: String)
    }

    private var changeName: Result<Void, Error>

    public init(changeName: Result<Void, Error> = .success(())) {
        self.changeName = changeName
    }

    public func changeName(
        firstName: String,
        lastName: String
    ) async throws {
        actions.append(.changeName(firstName: firstName, lastName: lastName))
        return try changeName.get()
    }
}
