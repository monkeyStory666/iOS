// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGAPresentation
import MEGAPresentationMocks
import MEGATest
import MEGASharedRepoL10n
import MEGAUIComponent
import Testing

struct ChangeNameViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.firstName.isEmpty)
        #expect(sut.lastName.isEmpty)
        #expect(sut.firstNameFieldState == .normal)
        #expect(sut.lastNameFieldState == .normal)
        #expect(sut.isUpdating == false)
    }

    @Test func testOnAppear_shouldUpdateDefaultNameValues() async {
        let expectedFirstName = String.random(withPrefix: "firstName")
        let expectedLastName = String.random(withPrefix: "lastName")
        let mockAccountUseCase = MockFetchAccountUseCase(
            fetchAccount: .success(.sample(
                firstName: expectedFirstName,
                lastName: expectedLastName
            ))
        )
        let sut = makeSUT(fetchAccountUseCase: mockAccountUseCase)

        await sut.onAppear()

        #expect(sut.firstName == expectedFirstName)
        #expect(sut.lastName == expectedLastName)
        #expect(sut.firstNameFieldState == .normal)
        #expect(sut.lastNameFieldState == .normal)
    }

    @Test func testButtonState_whenUpdating_shouldBeLoading() async {
        await assertButtonState_onAppear(shouldBe: .load, isUpdating: true)
    }

    @Test func testButtonState_whenValid_shouldBeDefault() async {
        await assertButtonState_onAppear(
            shouldBe: .default,
            firstName: .random(withPrefix: "validFirstName"),
            lastName: .random(withPrefix: "validLastName")
        )
    }

    @Test func testDidTapUpdate_whenFirstNameIsEmpty_shouldShowWarning() async {
        let sut = makeSUT()

        await sut.didTapUpdate()

        #expect(sut.route == nil)
        #expect(
            sut.firstNameFieldState ==
            .warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName)
        )
    }

    @Test func testDidTapUpdate_whenLastNameIsEmpty_shouldShowWarning() async {
        let sut = makeSUT()

        await sut.didTapUpdate()

        #expect(sut.route == nil)
        #expect(
            sut.lastNameFieldState ==
            .warning(SharedStrings.Localizable.Account.ChangeName.enterLastName)
        )
    }

    @Test func testDidTapUpdate_shouldUpdateIsUpdating() async {
        func assertUpdateIsUpdating(
            whenResult changeNameResult: Result<Void, Error>
        ) async {
            let sut = makeSUT(
                changeNameUseCase: MockChangeNameUseCase(
                    changeName: changeNameResult
                )
            )
            let isUpdatingSpy = sut.$isUpdating.spy()

            await sut.onAppear()
            await sut.didTapUpdate()

            #expect(isUpdatingSpy.values == [true, false])
        }

        await assertUpdateIsUpdating(whenResult: .success(()))
        await assertUpdateIsUpdating(whenResult: .failure(ErrorInTest()))
    }

    @Test func testDidTapUpdate_shouldChangeName() async {
        let mockChangeNameUseCase = MockChangeNameUseCase()
        let sut = makeSUT(changeNameUseCase: mockChangeNameUseCase)
        sut.firstName = .random()
        sut.lastName = .random()

        await sut.didTapUpdate()

        #expect(sut.route == .nameChanged)
        mockChangeNameUseCase.swt.assertActions(shouldBe: [
            .changeName(
                firstName: sut.firstName,
                lastName: sut.lastName
            )
        ])
    }

    @Test func testDidTapUpdate_whenChangeNameSucceeds_shouldDisplaySnackbar() async {
        let mockSnackbarDisplayer = MockSnackbarDisplayer()
        let sut = makeSUT(
            changeNameUseCase: MockChangeNameUseCase(
                changeName: .success(())
            ),
            snackbarDisplayer: mockSnackbarDisplayer
        )

        await sut.onAppear()
        await sut.didTapUpdate()

        #expect(sut.route == .nameChanged)
        mockSnackbarDisplayer.swt.assertActions(shouldBe: [
            .display(.init(
                text: SharedStrings.Localizable.Account.ChangeName.Snackbar.success
            ))
        ])
    }

    @Test func testDidTapUpdate_shouldRouteToNameChanged_onlyWhenChangeNameSucceeds() async {
        func assert(
            whenResult changeNameResult: Result<Void, Error>,
            shouldReturn expectedResult: Bool,
            line: UInt = #line
        ) async {
            let sut = makeSUT(
                changeNameUseCase: MockChangeNameUseCase(
                    changeName: changeNameResult
                )
            )

            await sut.onAppear()
            await sut.didTapUpdate()

            #expect((sut.route == .nameChanged) == expectedResult)
        }

        await assert(
            whenResult: .success(()),
            shouldReturn: true
        )

        await assert(
            whenResult: .failure(ErrorInTest()),
            shouldReturn: false
        )
    }

    @Test func testObserveChanges_whenFirstNameIsChanged_shouldChangeFromWarningToNormal() async {
        let sut = makeSUT()

        await sut.onAppear()

        let firstNameFieldStateValues = sut.$firstNameFieldState.spy()
        sut.firstNameFieldState = .warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName)

        sut.firstName = "Updated FirstName"

        #expect(
            firstNameFieldStateValues.values ==
            [.warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName), .normal]
        )
    }

    @Test func testObserveChangesForLastName_whenLastNameIsChanged_shouldChangeFromWarningToNormal() async {
        let sut = makeSUT()

        await sut.onAppear()

        let firstNameFieldStateValues = sut.$lastNameFieldState.spy()
        sut.lastNameFieldState = .warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName)

        sut.lastName = "Updated LastName"

        #expect(
            firstNameFieldStateValues.values ==
            [.warning(SharedStrings.Localizable.Account.ChangeName.enterFirstName), .normal]
        )
    }

    @Test func testDidTapDismiss_shouldRouteToDismiss() {
        let sut = makeSUT()

        sut.didTapDismiss()

        #expect(sut.route?.isDismissed == true)
    }

    @Test func isAnyFieldChanged_shouldRespondToFieldChanges() async {
        let mockAccountUseCase = MockFetchAccountUseCase(
            fetchAccount: .success(.sample(
                firstName: "John",
                lastName: "Doe"
            ))
        )
        let sut = makeSUT(fetchAccountUseCase: mockAccountUseCase)

        await sut.onAppear()

        sut.firstName = "Charlie"

        #expect(sut.isAnyFieldChanged == true)
        #expect(sut.buttonState == .default)

        sut.firstName = "John"

        #expect(sut.isAnyFieldChanged == false)
        #expect(sut.buttonState == .disabled)
    }

    @Test func nameMaxCharacterLimit_shouldLimitTo40Characters() {
        #expect(makeSUT().nameMaxCharacterLimit == 40)
    }
    
    // MARK: - Test Helpers

    private typealias SUT = ChangeNameViewModel
    private func makeSUT(
        fetchAccountUseCase: some FetchAccountUseCaseProtocol = MockFetchAccountUseCase(),
        changeNameUseCase: some ChangeNameUseCaseProtocol = MockChangeNameUseCase(),
        snackbarDisplayer: some SnackbarDisplaying = MockSnackbarDisplayer(),
        file: StaticString = #file, line: UInt = #line
    ) -> SUT {
        ChangeNameViewModel(
            snackbarDisplayer: snackbarDisplayer,
            fetchAccountUseCase: fetchAccountUseCase,
            changeNameUseCase: changeNameUseCase
        )
    }

    private func assertFirstNameFieldState(
        shouldBe expectedFieldState: ChangeNameViewModel.FieldState,
        whenFirstNameIs firstName: String
    ) async {
        let sut = makeSUT()

        await sut.onAppear()

        sut.firstName = firstName

        #expect(sut.firstNameFieldState == expectedFieldState)
    }

    private func assertLastNameFieldState(
        shouldBe expectedFieldState: ChangeNameViewModel.FieldState,
        whenLastNameIs firstName: String,
        line: UInt = #line
    ) async {
        let sut = makeSUT()

        await sut.onAppear()

        sut.lastName = firstName

        #expect(sut.lastNameFieldState == expectedFieldState)
    }

    private func assertButtonState_onAppear(
        shouldBe expectedButtonState: MEGAButtonStyle.State,
        firstName: String = "firstName",
        lastName: String = "lastName",
        isUpdating: Bool = false,
        defaultFirstName: String = "defaultFirstName",
        defaultLastName: String = "defaultLastName",
        line: UInt = #line
    ) async {
        let mockAccountUseCase = MockFetchAccountUseCase(
            fetchAccount: .success(.sample(
                firstName: defaultFirstName,
                lastName: defaultLastName
            ))
        )
        let sut = makeSUT(fetchAccountUseCase: mockAccountUseCase)

        await sut.onAppear()

        sut.isUpdating = isUpdating
        sut.firstName = firstName
        sut.lastName = lastName

        #expect(sut.buttonState == expectedButtonState)
    }
}
