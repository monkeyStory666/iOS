// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import Foundation
import MEGAAccountManagementMocks
import MEGASwift
import MEGATest
import Testing

@Suite(.serialized)
final class DeleteAccountUseCaseTests {
    private var sut: DeleteAccountUseCase!
    private var cancellable: Cancellable?

    private var mockRepo: MockDeleteAccountRepository!
    private var logoutPollingSubject: PassthroughSubject<Date, Never>!

    init() {
        cancellable = nil
        logoutPollingSubject = .init()
        mockRepo = MockDeleteAccountRepository()
        sut = makeSUT(repository: mockRepo)
    }

    deinit {
        logoutPollingSubject = nil
        mockRepo = nil
        sut = nil
        cancellable = nil
    }

    // MARK: - Test Cases

    @Test func testMyEmail_shouldReturnMyEmailFromRepository() {
        let expectedEmail = String.random(withPrefix: "email")
        mockRepo._myEmail = expectedEmail

        #expect(sut.myEmail() == expectedEmail)
    }

    @Test func testDeleteAccount_shouldDeleteAccountWithCorrectPin() async {
        let pin = String.random(length: 6)

        try? await sut.deleteAccount(with: pin)

        mockRepo.swt.assertActions(shouldBe: [.deleteAccount(pin: pin)])
    }

    @Test func testDeleteAccount_shouldNotThrowWhenSucceeded() async throws {
        mockRepo._deleteAccountResult = .success(())

        try await sut.deleteAccount(with: .random())
    }

    @Test func testDeleteAccount_whenFailed_shouldThrow() async {
        mockRepo._deleteAccountResult = .failure(.twoFactorAuthenticationRequired)

        await #expect(performing: {
            try await sut.deleteAccount(with: .random())
        }, throws: { error in
            isError(error, equalTo: DeleteAccountRepository.Error.twoFactorAuthenticationRequired)
        })
    }

    @Test func testFetchSubscriptionPlatform_shouldNotThrowWhenSucceeded() async throws {
        func assert(
            whenPlatform subscriptionPlatform: SubscriptionPlatform
        ) async throws {
            mockRepo._fetchSubscriptionPlatform = .success(subscriptionPlatform)

            #expect(try await sut.fetchSubscriptionPlatform() == subscriptionPlatform)
        }

        try await assert(whenPlatform: .apple)
        try await assert(whenPlatform: .android)
        try await assert(whenPlatform: .other)
    }

    @Test func testFetchSubscriptionPlatform_whenFailed_shouldThrow() async {
        mockRepo._fetchSubscriptionPlatform = .failure(ErrorInTest())

        await #expect(performing: {
            _ = try await sut.fetchSubscriptionPlatform()
        }, throws: { _ in true })
    }

    @Test func testPollForLogout_whenLogoutPublisherEmits_untilCancelled_shouldPollRepositoryHasLoggedOut() async {
        mockRepo._hasLoggedOut = false

        cancellable = sut.pollForLogout()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: 0.times)

        await waitAndAssertLogoutCalled()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: .once)

        await waitAndAssertLogoutCalled()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: .twice)

        cancellable?.cancel()

        await waitOneSecondAndAssertLogoutNotCalled()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: .twice)
    }

    @Test func testPollForLogout_whenLogoutPublisherEmits_untilLoggedOut_shouldPollRepositoryHasLoggedOut() async {
        mockRepo._hasLoggedOut = false
        cancellable = sut.pollForLogout()
        await waitAndAssertLogoutCalled()

        mockRepo._hasLoggedOut = true
        await waitAndAssertLogoutCalled()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: .twice)

        await waitOneSecondAndAssertLogoutNotCalled()
        mockRepo.swt.assert(.hasLoggedOut, isCalled: .twice)
    }

    @Test func testPollForLogout_whenLogoutPublisherEmits_andHasLoggedOut_shouldCallLogoutHandler() async {
        mockRepo._hasLoggedOut = false
        var logoutHandlerCalledTimes = 0
        let cancellable = sut.pollForLogout(logoutHandler: {
            logoutHandlerCalledTimes += 1
        })
        await waitAndAssertLogoutCalled()

        mockRepo._hasLoggedOut = true
        await waitAndAssertLogoutCalled()
        await waitOneSecondAndAssertLogoutNotCalled()

        #expect(logoutHandlerCalledTimes == 1)

        cancellable.cancel()
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repository: any DeleteAccountRepositoryProtocol
    ) -> DeleteAccountUseCase {
        DeleteAccountUseCase(
            repository: repository,
            logoutPollingPublisher: logoutPollingSubject.eraseToAnyPublisher()
        )
    }

    private func waitAndAssertLogoutCalled() async {
        await confirmation(
            in: mockRepo.actionsPublisher.filter { $0.last == .hasLoggedOut }
        ) { [weak self] in
            self?.logoutPollingSubject.send(Date())
        }
        _ = await sut.logoutPollTask?.value
    }

    private func waitOneSecondAndAssertLogoutNotCalled() async {
        await confirmation(
            in: mockRepo.actionsPublisher.filter { $0.last == .hasLoggedOut },
            expectedCount: 0,
            timeout: 1
        ) { [weak self] in
            self?.logoutPollingSubject.send(Date())
        }
    }
}
