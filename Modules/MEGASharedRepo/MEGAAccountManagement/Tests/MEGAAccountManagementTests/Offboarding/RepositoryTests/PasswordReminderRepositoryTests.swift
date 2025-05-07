// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct PasswordReminderRepositoryTests {
    @Test func testPasswordReminderBlocked_whenRequestSucceeded_shouldNotThrow() async throws {
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderBlockedCompletion: requestDelegateFinished(error: .apiOk)
            )
        )

        try await sut.passwordReminderBlocked()
    }

    @Test func testPasswordReminderBlocked_whenRequestFailed_shouldThrow() async throws {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderBlockedCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(performing: {
            try await sut.passwordReminderBlocked()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func testPasswordReminderSkipped_whenRequestSucceeded_shouldNotThrow() async throws {
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderSkippedCompletion: requestDelegateFinished(error: .apiOk)
            )
        )

        try await sut.passwordReminderSkipped()
    }

    @Test func testPasswordReminderSkipped_whenRequestFailed_shouldThrow() async throws {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderSkippedCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(performing: {
            try await sut.passwordReminderSkipped()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func testPasswordReminderSucceeded_whenRequestSucceeded_shouldNotThrow() async throws {
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderSucceededCompletion: requestDelegateFinished(error: .apiOk)
            )
        )

        try await sut.passwordReminderSucceeded()
    }

    @Test func testPasswordReminderSucceeded_whenRequestFailed_shouldThrow() async throws {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                reminderSucceededCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(performing: {
            try await sut.passwordReminderSucceeded()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func testShouldShowPasswordReminder_whenSucceeded_shouldPassAtLogout_andReturnRequestFlag() async throws {
        func assert(
            atLogout: Bool,
            whenSdkFlag sdkFlag: Bool,
            shouldShowReminder: Bool,
            line: UInt = #line
        ) async throws {
            let mockSdk = MockPasswordReminderSdk(
                shouldShowReminderCompletion: requestDelegateFinished(
                    request: MockSdkRequest(flag: sdkFlag),
                    error: .apiOk
                )
            )
            let sut = makeSUT(sdk: mockSdk)

            let result = try await sut.shouldShowPasswordReminder(atLogout: atLogout)

            #expect(mockSdk.shouldShowPasswordReminderCalls == [atLogout])
            #expect(result == shouldShowReminder)
        }

        try await assert(atLogout: true, whenSdkFlag: true, shouldShowReminder: true)
        try await assert(atLogout: true, whenSdkFlag: false, shouldShowReminder: false)
        try await assert(atLogout: false, whenSdkFlag: false, shouldShowReminder: false)
        try await assert(atLogout: false, whenSdkFlag: true, shouldShowReminder: true)
    }

    @Test func testShouldShowPasswordReminder_whenRequestFailed_shouldThrowError() async {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(
            sdk: MockPasswordReminderSdk(
                shouldShowReminderCompletion: requestDelegateFinished(
                    error: expectedError
                )
            )
        )

        await #expect(performing: {
            _ = try await sut.shouldShowPasswordReminder(atLogout: .random())
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockPasswordReminderSdk = MockPasswordReminderSdk()
    ) -> PasswordReminderRepository {
        PasswordReminderRepository(sdk: sdk)
    }
}

private final class MockPasswordReminderSdk: MEGASdk, @unchecked Sendable {
    var shouldShowPasswordReminderCalls: [Bool] = []

    var reminderBlockedCompletion: RequestDelegateStub
    var reminderSkippedCompletion: RequestDelegateStub
    var reminderSucceededCompletion: RequestDelegateStub
    var shouldShowReminderCompletion: RequestDelegateStub

    init(
        reminderBlockedCompletion: @escaping RequestDelegateStub = { _, _ in },
        reminderSkippedCompletion: @escaping RequestDelegateStub = { _, _ in },
        reminderSucceededCompletion: @escaping RequestDelegateStub = { _, _ in },
        shouldShowReminderCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self.reminderBlockedCompletion = reminderBlockedCompletion
        self.reminderSkippedCompletion = reminderSkippedCompletion
        self.reminderSucceededCompletion = reminderSucceededCompletion
        self.shouldShowReminderCompletion = shouldShowReminderCompletion
        super.init()
    }

    override func passwordReminderDialogBlocked(
        with delegate: MEGARequestDelegate
    ) {
        reminderBlockedCompletion(delegate, self)
    }

    override func passwordReminderDialogSkipped(
        with delegate: MEGARequestDelegate
    ) {
        reminderSkippedCompletion(delegate, self)
    }

    override func passwordReminderDialogSucceeded(
        with delegate: MEGARequestDelegate
    ) {
        reminderSucceededCompletion(delegate, self)
    }

    override func shouldShowPasswordReminderDialog(
        atLogout: Bool,
        delegate: MEGARequestDelegate
    ) {
        shouldShowPasswordReminderCalls.append(atLogout)
        shouldShowReminderCompletion(delegate, self)
    }
}
