// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

@Suite(.serialized)
final class RemoteAccountRepositoryTests {
    init() {
        MockAccountSdk.setUp()
    }

    deinit {
        MockAccountSdk.tearDown()
    }

    @Test func fetch_shouldCallGetUserDataInSdk() async {
        let mockSdk = MockAccountSdk(
            getUserDataCompletion: requestDelegateFinished()
        )
        let sut = makeSUT(sdk: mockSdk)

        _ = try? await sut.fetch()

        #expect(mockSdk.getUserDataCallCount == .once)
    }

    @Test func fetch_whenGetUserDataFromSdkFailed_shouldThrowError() async {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(sdk: MockAccountSdk(
            getUserDataCompletion: requestDelegateFinished(error: expectedError)
        ))

        await #expect(performing: {
            _ = try await sut.fetch()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    @Test func fetch_whenFetchDataSucceed_butNoEmail_shouldThrowEmailNotFound() async {
        let sut = makeSUT(sdk: MockAccountSdk(
            myEmail: nil,
            getUserDataCompletion: requestDelegateFinished()
        ))

        await #expect(performing: {
            _ = try await sut.fetch()
        }, throws: { error in
            error as? AccountRepositoryError == .emailNotFound
        })
    }

    @Test func fetch_whenFetchDataSucceed_butNoUser_shouldThrowEmailNotFound() async {
        let sut = makeSUT(sdk: MockAccountSdk(
            myUser: nil,
            getUserDataCompletion: requestDelegateFinished()
        ))

        await #expect(performing: {
            _ = try await sut.fetch()
        }, throws: { error in
            error as? AccountRepositoryError == .userNotFound
        })
    }

    @Test func Fetch_whenFetchDataSucceed_butBase64HandleNil_shouldThrowEmailNotFound() async {
        let sut = makeSUT(sdk: MockAccountSdk(
            base64HandleForUserHandle: nil,
            getUserDataCompletion: requestDelegateFinished()
        ))

        await #expect(performing: {
            _ = try await sut.fetch()
        }, throws: { error in
            error as? AccountRepositoryError == .base64handleNotFound
        })
    }

    struct FetchNameNoEntErrorArguments {
        let firstNameResult: RequestDelegateStub
        let lastNameResult: RequestDelegateStub
        let expectedFirstNameEmpty: Bool
        let expectedLastNameEmpty: Bool
    }

    @Test(arguments: [
        .init(
            firstNameResult: requestDelegateFinished(error: MockSdkError(type: .apiENoent)),
            lastNameResult: requestDelegateFinished(request: MockSdkRequest(text: .random())),
            expectedFirstNameEmpty: true,
            expectedLastNameEmpty: false
        ),
        .init(
            firstNameResult: requestDelegateFinished(request: MockSdkRequest(text: .random())),
            lastNameResult: requestDelegateFinished(error: MockSdkError(type: .apiENoent)),
            expectedFirstNameEmpty: false,
            expectedLastNameEmpty: true
        ),
        .init(
            firstNameResult: requestDelegateFinished(error: MockSdkError(type: .apiENoent)),
            lastNameResult: requestDelegateFinished(error: MockSdkError(type: .apiENoent)),
            expectedFirstNameEmpty: true,
            expectedLastNameEmpty: true
        )
    ] as [FetchNameNoEntErrorArguments])
    func fetch_whenGetNameNoEntError_shouldNotThrowError_andReturnEmptyString(
        arguments: FetchNameNoEntErrorArguments
    ) async throws {
        let sut = makeSUT(sdk: MockAccountSdk(
            getUserAttributeCompletion: [
                .firstname: arguments.firstNameResult,
                .lastname: arguments.lastNameResult
            ]
        ))

        let result = try await sut.fetch()

        #expect(result.firstName.isEmpty == arguments.expectedFirstNameEmpty)
        #expect(result.lastName.isEmpty == arguments.expectedLastNameEmpty)
    }

    struct FetchNameUnhandledErrorArguments {
        let firstNameError: Bool
        let lastNameError: Bool
    }

    @Test(arguments: [
        .init(
            firstNameError: true,
            lastNameError: false
        ),
        .init(
            firstNameError: false,
            lastNameError: true
        ),
        .init(
            firstNameError: true,
            lastNameError: true
        )
    ] as [FetchNameUnhandledErrorArguments])
    func fetch_whenGetOtherError_shouldThrowThatError(
        arguments: FetchNameUnhandledErrorArguments
    ) async throws {
        let expectedError = MockSdkError.anyError
        let errorStub = requestDelegateFinished(error: expectedError)
        let successStub = requestDelegateFinished(request: MockSdkRequest(text: .random()))
        let sut = makeSUT(sdk: MockAccountSdk(
            getUserAttributeCompletion: [
                .firstname: arguments.firstNameError ? errorStub : successStub,
                .lastname: arguments.lastNameError ? errorStub : successStub
            ]
        ))

        await #expect(
            performing: { _ = try await sut.fetch() },
            throws: { error in
                (error as? MEGAError) == expectedError
            }
        )
    }

    @Test func fetch_shouldReturnCorrectData_fromSDK() async throws {
        let expectedEmail = String.random()
        let userHandle = UInt64.random()
        let expectedUser = MockUser(handle: userHandle)
        let expectedFirstName = String.random()
        let expectedLastName = String.random()
        let expectedBase64 = String.random()

        let sut = makeSUT(
            sdk: MockAccountSdk(
                myEmail: expectedEmail,
                myUser: expectedUser,
                base64HandleForUserHandle: expectedBase64,
                getUserAttributeCompletion: [
                    .firstname: requestDelegateFinished(
                        request: MockSdkRequest(text: expectedFirstName)
                    ),
                    .lastname: requestDelegateFinished(
                        request: MockSdkRequest(text: expectedLastName)
                    )
                ]
            )
        )

        let data = try await sut.fetch()

        #expect(data.email == expectedEmail)
        #expect(data.handle == userHandle)
        #expect(data.base64Handle == expectedBase64)
        #expect(data.firstName == expectedFirstName)
        #expect(data.lastName == expectedLastName)
        #expect(MockAccountSdk.base64handleCalls == [userHandle])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockAccountSdk = MockAccountSdk()
    ) -> RemoteAccountRepository<MockAccountSdk> {
        RemoteAccountRepository(sdk: sdk)
    }
}

private final class MockUser: MEGAUser {
    var _handle: UInt64

    init(handle: UInt64 = .random()) {
        self._handle = handle
    }

    override var handle: UInt64 {
        _handle
    }
}

private final class MockAccountSdk: MEGASdk, @unchecked Sendable {
    static var base64handleCalls: [UInt64] = []
    static var _base64HandleForUserHandle: String?

    var getUserDataCallCount: CallFrequency = 0

    var _myEmail: String?
    var _myUser: MEGAUser?

    var getUserDataCompletion: RequestDelegateStub
    var getUserAttributeCompletion: [MEGAUserAttribute: RequestDelegateStub]

    init(
        myEmail: String? = .random(),
        myUser: MEGAUser? = MockUser(),
        base64HandleForUserHandle: String? = .random(),
        getUserDataCompletion: @escaping RequestDelegateStub = requestDelegateFinished(),
        getUserAttributeCompletion: [MEGAUserAttribute: RequestDelegateStub] = [
            .firstname: requestDelegateFinished(),
            .lastname: requestDelegateFinished()
        ]
    ) {
        self._myEmail = myEmail
        self._myUser = myUser
        self.getUserDataCompletion = getUserDataCompletion
        self.getUserAttributeCompletion = getUserAttributeCompletion
        Self._base64HandleForUserHandle = base64HandleForUserHandle
        super.init()
    }

    override var myEmail: String? {
        _myEmail
    }

    override var myUser: MEGAUser? {
        _myUser
    }

    override func getUserData(with delegate: MEGARequestDelegate) {
        getUserDataCallCount += 1
        getUserDataCompletion(delegate, self)
    }

    override func getUserAttributeType(
        _ type: MEGAUserAttribute,
        delegate: MEGARequestDelegate
    ) {
        getUserAttributeCompletion[type]?(delegate, self)
    }

    override final class func base64Handle(
        forUserHandle userhandle: UInt64
    ) -> String? {
        Self.base64handleCalls.append(userhandle)
        return _base64HandleForUserHandle
    }

    final class func setUp() {
        base64handleCalls = []
    }

    final class func tearDown() {
        base64handleCalls = []
    }
}
