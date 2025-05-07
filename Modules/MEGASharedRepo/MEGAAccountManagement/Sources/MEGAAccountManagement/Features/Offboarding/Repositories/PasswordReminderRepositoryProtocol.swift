// Copyright © 2023 MEGA Limited. All rights reserved.

public protocol PasswordReminderRepositoryProtocol {
    func passwordReminderBlocked() async throws
    func passwordReminderSkipped() async throws
    func passwordReminderSucceeded() async throws
    func shouldShowPasswordReminder(atLogout: Bool) async throws -> Bool
}
