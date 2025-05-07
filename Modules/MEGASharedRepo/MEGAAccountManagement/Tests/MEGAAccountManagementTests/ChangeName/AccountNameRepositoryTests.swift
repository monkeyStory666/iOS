// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGASDKRepoMocks
import MEGATest
import Testing

struct AccountNameRepositoryTests {
    @Test func testChangeName_whenSdkError_shouldThrowRightError() async {
        func assert(
            firstNameSdkError: MEGAError,
            lastNameSdkError: MEGAError,
            expectedErrorThrown: AccountNameRepository.ChangeNameError?,
            line: UInt = #line
        ) async {
            let mockSdk = MockAccountNameSdk(
                setUserAttributeCompletion: [
                    .firstname: requestDelegateFinished(error: firstNameSdkError),
                    .lastname: requestDelegateFinished(error: lastNameSdkError)
                ]
            )
            let sut = makeSUT(sdk: mockSdk)

            var errorThrown: Error?
            do {
                try await sut.changeName(firstName: .random(), lastName: .random())
            } catch {
                errorThrown = error
            }

            #expect(
                errorThrown as? AccountNameRepository.ChangeNameError ==
                expectedErrorThrown
            )
        }

        await assert(
            firstNameSdkError: .apiOk,
            lastNameSdkError: .apiOk,
            expectedErrorThrown: nil
        )

        await assert(
            firstNameSdkError: .anyError,
            lastNameSdkError: .apiOk,
            expectedErrorThrown: .failedToChangeFirstName
        )

        await assert(
            firstNameSdkError: .apiOk,
            lastNameSdkError: .anyError,
            expectedErrorThrown: .failedToChangeLastName
        )

        await assert(
            firstNameSdkError: .anyError,
            lastNameSdkError: .anyError,
            expectedErrorThrown: .failedToChangeName
        )
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockAccountNameSdk = MockAccountNameSdk()
    ) -> AccountNameRepository {
        AccountNameRepository(sdk: sdk)
    }
}

private final class MockAccountNameSdk: MEGASdk, @unchecked Sendable {
    var setUserAttributeTypeCalls = [SetUserAttributeArguments]()

    var setUserAttributeCompletion = [MEGAUserAttribute: RequestDelegateStub]()

    init(
        setUserAttributeCompletion: [MEGAUserAttribute: RequestDelegateStub] = [:]
    ) {
        self.setUserAttributeCompletion = setUserAttributeCompletion
        super.init()
    }

    typealias SetUserAttributeArguments = (type: MEGAUserAttribute, value: String)

    override func setUserAttributeType(
        _ type: MEGAUserAttribute,
        value: String,
        delegate: MEGARequestDelegate
    ) {
        setUserAttributeTypeCalls.append((type, value))
        setUserAttributeCompletion[type]?(delegate, self)
    }
}
