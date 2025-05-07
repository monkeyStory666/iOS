// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest

public final class MockPasswordReminderRepository:
    MockObject<MockPasswordReminderRepository.Action>,
    PasswordReminderRepositoryProtocol {
    public enum Action: Equatable {
        case passwordReminderBlocked
        case passwordReminderSkipped
        case passwordReminderSucceeded
        case shouldShowPasswordReminder(atLogout: Bool)
    }

    public var _shouldShowPasswordReminder: Bool

    public init(
        shouldShowPasswordReminder: Bool = true
    ) {
        self._shouldShowPasswordReminder = shouldShowPasswordReminder
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

    public func shouldShowPasswordReminder(
        atLogout: Bool
    ) async throws -> Bool {
        actions.append(.shouldShowPasswordReminder(
            atLogout: atLogout
        ))
        return _shouldShowPasswordReminder
    }
}
