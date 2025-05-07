// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGASettings
import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGATest
import XCTest

final class AccountDetailInformationViewModelTests: XCTestCase {
    private var expectedAccount: AccountEntity { .dummy }

    func testInitialState() {
        let sut = makeSUT()

        XCTAssertNil(sut.account)
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.subtitle.isEmpty)
        XCTAssertTrue(sut.titleIsRedacted)
        XCTAssertTrue(sut.subtitleIsRedacted)
    }

    func testOnAppear_shouldFetchRefreshedAccount() async {
        let mockFetchUseCase = MockFetchAccountUseCase(
            fetchRefreshedAccount: .success(expectedAccount)
        )
        let sut = makeSUT(fetchAccountUseCase: mockFetchUseCase)

        await sut.onAppear()

        XCTAssertEqual(sut.account, expectedAccount)
        XCTAssertEqual(sut.title, expectedAccount.fullName)
        XCTAssertEqual(sut.subtitle, expectedAccount.email)
        XCTAssertFalse(sut.titleIsRedacted)
        XCTAssertFalse(sut.subtitleIsRedacted)
        mockFetchUseCase.assertActions(shouldBe: [.fetchRefreshedAccount(nil)])
    }

    func testOnRefresh_shouldFetchRefreshedAccount() async {
        let mockFetchUseCase = MockFetchAccountUseCase(
            fetchRefreshedAccount: .success(expectedAccount)
        )
        let sut = makeSUT(fetchAccountUseCase: mockFetchUseCase)

        await sut.onRefresh()

        XCTAssertEqual(sut.account, expectedAccount)
        XCTAssertEqual(sut.title, expectedAccount.fullName)
        XCTAssertEqual(sut.subtitle, expectedAccount.email)
        XCTAssertFalse(sut.titleIsRedacted)
        XCTAssertFalse(sut.subtitleIsRedacted)
        mockFetchUseCase.assertActions(shouldBe: [.fetchRefreshedAccount(nil)])
    }
    
    func testOnRefresh_whenAvatarViewIsDefault_shouldReloadDefaultAvatarView() async {
        let mockFetchUseCase = MockFetchAccountUseCase(
            fetchRefreshedAccount: .success(expectedAccount)
        )
        let mockGenerateDefaultAvatarUseCase = MockGenerateDefaultAvatarUseCase()
        let avatarViewModel = await makeAvatarViewModel(
            generateDefaultAvatarUseCase: mockGenerateDefaultAvatarUseCase,
            isAvatarViewDefault: true
        )
        let sut = makeSUT(
            fetchAccountUseCase: mockFetchUseCase,
            avatarViewModel: avatarViewModel
        )

        await sut.onRefresh()
        
        mockGenerateDefaultAvatarUseCase.assert(.defaultAvatarForCurrentUser, isCalled: .once)
    }

    func testOnRefresh_whenAvatarViewIsNotDefault_shouldNotReloadDefaultAvatarView() async {
        let mockFetchUseCase = MockFetchAccountUseCase(
            fetchRefreshedAccount: .success(expectedAccount)
        )
        let mockGenerateDefaultAvatarUseCase = MockGenerateDefaultAvatarUseCase()
        let avatarViewModel = await makeAvatarViewModel(
            generateDefaultAvatarUseCase: mockGenerateDefaultAvatarUseCase,
            isAvatarViewDefault: false
        )
        let sut = makeSUT(
            fetchAccountUseCase: mockFetchUseCase,
            avatarViewModel: avatarViewModel
        )

        await sut.onRefresh()
        
        mockGenerateDefaultAvatarUseCase.assert(.defaultAvatarForCurrentUser, isCalled: .zero)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        fetchAccountUseCase: some FetchAccountUseCaseProtocol = MockFetchAccountUseCase(),
        avatarViewModel: AvatarViewModel = AvatarViewModel(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> AccountDetailInformationViewModel {
        let sut = AccountDetailInformationViewModel(
            fetchAccountUseCase: fetchAccountUseCase,
            avatarViewModel: avatarViewModel
        )
        trackForMemoryLeaks(on: sut, file: file, line: line)
        return sut
    }
    
    private func makeAvatarViewModel(
        generateDefaultAvatarUseCase: some GenerateDefaultAvatarUseCaseProtocol,
        isAvatarViewDefault: Bool
    ) async ->  AvatarViewModel {
        let defaultAvatarViewModel = DefaultAvatarViewModel(
            generateDefaultAvatarUseCase: generateDefaultAvatarUseCase
        )
        let mockFetchAvatarUseCase = MockFetchUIImageAvatarUseCase(
            fetchAvatarForCurrentUser: isAvatarViewDefault ? nil : UIImage()
        )
        let avatarViewModel = AvatarViewModel(
            fetchAvatarUseCase: mockFetchAvatarUseCase,
            defaultAvatarViewModel: defaultAvatarViewModel
        )
        await avatarViewModel.reload()
        return avatarViewModel
    }
}
