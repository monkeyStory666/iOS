// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGASdk
import MEGASDKRepo
import MEGASDKRepoMocks
import MEGASwift
import Testing

struct DeleteAccountRepositoryTests {
    @Test func myEmail_shouldGetFromSdk() {
        let expectedEmail = String.random()
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                _myEmail: expectedEmail
            )
        )

        #expect(sut.myEmail() == expectedEmail)
    }

    @Test func deleteAccount_withoutPin_whenCancelAccountSuccess_shouldNotThrow() async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                cancelAccountCompletion: requestDelegateFinished()
            )
        )

        try await sut.deleteAccount(with: nil)
    }

    @Test(
        arguments: [
            (MockSdkError.anyError, SUT.Error.generic),
            (MockSdkError(type: .apiEArgs), SUT.Error.twoFactorAuthenticationRequired),
            (MockSdkError(type: .apiEMFARequired), SUT.Error.twoFactorAuthenticationRequired)
        ]
    ) func deleteAccount_withoutPin_whenCancelAccountFailure_shouldThrow(
        arguments: (sdkError: MEGAError, expectedThrownError: Error)
    ) async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                cancelAccountCompletion: requestDelegateFinished(
                    error: arguments.sdkError
                )
            )
        )

        await #expect(performing: {
            try await sut.deleteAccount(with: nil)
        }, throws: { error in
            isError(error, equalTo: arguments.expectedThrownError)
        })
    }

    @Test func deleteAccount_withPin_whenMultiFactorAuthDeleteAccountSuccess_shouldNotThrow() async throws {
        let mockSdk = MockDeleteAccountSdk(
            multiFactorAuthCancelAccountCompletion: requestDelegateFinished()
        )
        let expectedPin = String.random()
        let sut = DeleteAccountRepository(sdk: mockSdk)

        try await sut.deleteAccount(with: expectedPin)

        #expect(mockSdk.multiFactorAuthCancelPinSpy == [expectedPin])
    }

    @Test(
        arguments: [
            (MockSdkError.anyError, SUT.Error.generic),
            (MockSdkError(type: .apiEFailed), SUT.Error.wrongPin)
        ]
    ) func deleteAccount_withPin_whenCancelAccountFailure_shouldThrow(
        arguments: (sdkError: MEGAError, expectedThrownError: Error)
    ) async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                multiFactorAuthCancelAccountCompletion: requestDelegateFinished(
                    error: arguments.sdkError
                )
            )
        )

        await #expect(performing: {
            try await sut.deleteAccount(with: .random())
        }, throws: { error in
            isError(error, equalTo: arguments.expectedThrownError)
        })
    }

    @Test func hasLoggedOut_whenSdkSuccess_shouldReturnFalse() async {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished()
            )
        )

        await #expect(sut.hasLoggedOut() == false)
    }

    @Test func hasLoggedOut_whenSdkError_shouldReturnTrue() async {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    error: MockSdkError(type: .apiEAccess)
                )
            )
        )

        #expect(await sut.hasLoggedOut())
    }

    @Test(
        arguments: [
            (MockSdkRequest(), MockSdkError.apiOk, SUT.Error.generic),
            (MockSdkRequest(), MockSdkError.anyError, SUT.Error.generic),
            (
                MockSdkRequest(accountDetails: MockDeleteAccountDetails(type: .free)),
                MockSdkError.apiOk,
                SUT.Error.generic
            )
        ]
    ) func fetcbSubscriptionPlatformErrors(
        arguments: (request: MEGARequest, sdkError: MEGAError, expectedError: Error)
    ) async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    request: arguments.request,
                    error: arguments.sdkError
                )
            )
        )

        await #expect(performing: {
            _ = try await sut.fetchSubscriptionPlatform()
        }, throws: { error in
            isError(error, equalTo: arguments.expectedError)
        })
    }

    struct FetchSubscriptionPlatformSuccessArguments {
        let subscriptionMethodId: MEGAPaymentMethod
        let expectedPlatform: SubscriptionPlatform
    }

    @Test(
        arguments: [
            MEGAPaymentMethod.astropay,
            MEGAPaymentMethod.balance,
            MEGAPaymentMethod.bitcoin,
            MEGAPaymentMethod.creditCard,
            MEGAPaymentMethod.directReseller,
            MEGAPaymentMethod.paypal,
            MEGAPaymentMethod.stripe,
            MEGAPaymentMethod.stripe2,
            MEGAPaymentMethod.huaweiWallet
        ]
    ) func fetcbSubscriptionPlatformSuccesses_withOtherSubscriptionPlatform(
        sdkMethod: MEGAPaymentMethod
    ) async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    request: MockSdkRequest(
                        accountDetails: MockDeleteAccountDetails(
                            subscriptionMethodId: sdkMethod
                        )
                    ), error: MockSdkError.apiOk
                )
            )
        )

        #expect(try await sut.fetchSubscriptionPlatform() == .other)
    }

    @Test func fetcbSubscriptionPlatformSuccesses_withAppleSubscriptionPlatform() async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    request: MockSdkRequest(
                        accountDetails: MockDeleteAccountDetails(
                            subscriptionMethodId: .itunes
                        )
                    ), error: MockSdkError.apiOk
                )
            )
        )

        #expect(try await sut.fetchSubscriptionPlatform() == .apple)
    }

    @Test func fetcbSubscriptionPlatformSuccesses_withAndroidSubscriptionPlatform() async throws {
        let sut = DeleteAccountRepository(
            sdk: MockDeleteAccountSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    request: MockSdkRequest(
                        accountDetails: MockDeleteAccountDetails(
                            subscriptionMethodId: .googleWallet
                        )
                    ), error: MockSdkError.apiOk
                )
            )
        )

        #expect(try await sut.fetchSubscriptionPlatform() == .android)
    }

    private typealias SUT = DeleteAccountRepository
}

private final class MockDeleteAccountSdk: MEGASdk, @unchecked Sendable {
    var multiFactorAuthCancelPinSpy: [String] = []

    var _myEmail: String?
    var cancelAccountCompletion: RequestDelegateStub
    var multiFactorAuthCancelAccountCompletion: RequestDelegateStub
    var getAccountDetailsCompletion: RequestDelegateStub

    init(
        _myEmail: String? = nil,
        cancelAccountCompletion: @escaping RequestDelegateStub = { _, _ in },
        multiFactorAuthCancelAccountCompletion: @escaping RequestDelegateStub = { _, _ in },
        getAccountDetailsCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self._myEmail = _myEmail
        self.cancelAccountCompletion = cancelAccountCompletion
        self.multiFactorAuthCancelAccountCompletion = multiFactorAuthCancelAccountCompletion
        self.getAccountDetailsCompletion = getAccountDetailsCompletion
        super.init()
    }

    override var myEmail: String? { _myEmail }

    override func cancelAccount(with delegate: any MEGARequestDelegate) {
        cancelAccountCompletion(delegate, self)
    }

    override func multiFactorAuthCancelAccount(withPin pin: String, delegate: any MEGARequestDelegate) {
        multiFactorAuthCancelPinSpy.append(pin)
        multiFactorAuthCancelAccountCompletion(delegate, self)
    }

    override func getAccountDetails(with delegate: any MEGARequestDelegate) {
        getAccountDetailsCompletion(delegate, self)
    }
}

private final class MockDeleteAccountDetails: MEGAAccountDetails {
    var _type: MEGAAccountType
    var _subscriptionMethodId: MEGAPaymentMethod

    init(
        type: MEGAAccountType = .proI,
        subscriptionMethodId: MEGAPaymentMethod = .itunes
    ) {
        _type = type
        _subscriptionMethodId = subscriptionMethodId
    }

    override var type: MEGAAccountType {
        _type
    }

    override var subscriptionMethodId: MEGAPaymentMethod {
        _subscriptionMethodId
    }
}
