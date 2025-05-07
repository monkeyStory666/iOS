// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockPasswordReminderUseCase:
    MockObject<MockPasswordReminderUseCase.Action>,
    PasswordReminderUseCaseProtocol {
    public enum Action: Equatable {
        case shouldShowPasswordReminder(atLogout: Bool)
        case passwordReminderBlocked
        case passwordReminderSkipped
        case passwordReminderSucceeded
    }

    public var _shouldShowPasswordReminder: Bool

    public init(shouldShowPasswordReminder: Bool = true) {
        self._shouldShowPasswordReminder = shouldShowPasswordReminder
    }

    public func shouldShowPasswordReminder(atLogout: Bool) async throws -> Bool {
        actions.append(.shouldShowPasswordReminder(atLogout: atLogout))
        return _shouldShowPasswordReminder
    }

    public func passwordReminderBlocked() async throws {
        actions.append(.passwordReminderBlocked)
    }

    public func passwordReminderSkipped() async throws {
        actions.append(.passwordReminderSkipped)
    }

    public func passwordReminderSucceeded() async throws {
        actions.append(.passwordReminderSucceeded)
    }
}
