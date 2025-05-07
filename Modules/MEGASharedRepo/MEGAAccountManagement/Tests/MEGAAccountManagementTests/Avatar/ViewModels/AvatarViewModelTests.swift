// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import Combine
import MEGAAccountManagementMocks
import MEGATest
import Testing
import UIKit

struct AvatarViewModelTests {
    @Test func testInitialState() {
        let sut = makeSUT()

        #expect(sut.state == .loading)
    }

    @Test func testLoad_shouldFetchAvatar_andUpdateState_toUserAvatar_ifExist() async {
        let expectedImage = UIImage()
        let mockUseCase = MockFetchUIImageAvatarUseCase(fetchAvatarForCurrentUser: expectedImage)
        let sut = makeSUT(fetchAvatarUseCase: mockUseCase)

        await sut.load()

        #expect(sut.state == .loaded(expectedImage))
        mockUseCase.swt.assertActions(shouldBe: [.fetchAvatarForCurrentUser(false)])
    }

    @Test func testLoad_shouldFetchAvatar_andUpdateState_toFailed_ifNoAvatar() async {
        let mockUseCase = MockFetchUIImageAvatarUseCase(fetchAvatarForCurrentUser: nil)
        let sut = makeSUT(fetchAvatarUseCase: mockUseCase)

        await sut.load()

        #expect(sut.state == .failed)
        mockUseCase.swt.assertActions(shouldBe: [.fetchAvatarForCurrentUser(false)])
    }

    @Test func testReload_shouldFetchAvatar_andUpdateState_toUserAvatar_ifExist() async {
        let expectedImage = UIImage()
        let mockUseCase = MockFetchUIImageAvatarUseCase(fetchAvatarForCurrentUser: expectedImage)
        let sut = makeSUT(fetchAvatarUseCase: mockUseCase)

        await sut.reload()

        #expect(sut.state == .loaded(expectedImage))
        mockUseCase.swt.assertActions(shouldBe: [.fetchAvatarForCurrentUser(true)])
    }

    @Test func testReload_shouldFetchAvatar_andUpdateState_toFailed_ifNoAvatar() async {
        let mockUseCase = MockFetchUIImageAvatarUseCase(fetchAvatarForCurrentUser: nil)
        let sut = makeSUT(fetchAvatarUseCase: mockUseCase)

        await sut.reload()

        #expect(sut.state == .failed)
        mockUseCase.swt.assertActions(shouldBe: [.fetchAvatarForCurrentUser(true)])
    }

    @Test func testRefreshUserData_shouldTriggerUpdate() async {
        let refreshUserDataUseCase = MockRefreshUserDataUseCase()
        let expectedImage = UIImage()
        let fetchAvatarUseCase = MockFetchUIImageAvatarUseCase(fetchAvatarForCurrentUser: expectedImage)
        let sut = makeSUT(
            fetchAvatarUseCase: fetchAvatarUseCase,
            refreshUserDataUseCase: refreshUserDataUseCase
        )

        await confirmation(in: sut.refreshUserDataPublisher) {
            refreshUserDataUseCase.notify()

            // We need to wait for update() which is triggered in refreshUserDataPublisher to finish to make sure
            // we don't have memory leak
            sleep(1)
        }

        fetchAvatarUseCase.swt.assertActions(shouldBe: [.fetchAvatarForCurrentUser(true)])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        fetchAvatarUseCase: some FetchUIImageAvatarUseCaseProtocol = MockFetchUIImageAvatarUseCase(),
        refreshUserDataUseCase: some RefreshUserDataNotificationUseCaseProtocol = MockRefreshUserDataUseCase()
    ) -> AvatarViewModel {
        AvatarViewModel(
            fetchAvatarUseCase: fetchAvatarUseCase,
            refreshUserDataUseCase: refreshUserDataUseCase
        )
    }
}

// MARK: - Mocks
final class MockFetchUIImageAvatarUseCase:
    MockObject<MockFetchUIImageAvatarUseCase.Action>,
    FetchUIImageAvatarUseCaseProtocol {
    enum Action: Equatable {
        case fetchAvatarForCurrentUser(Bool)
    }

    var _fetchAvatarForCurrentUser: UIImage?

    init(fetchAvatarForCurrentUser: UIImage? = nil) {
        self._fetchAvatarForCurrentUser = fetchAvatarForCurrentUser
    }

    func fetchAvatarForCurrentUser(reloadIgnoringLocalCache: Bool) async -> UIImage? {
        actions.append(.fetchAvatarForCurrentUser(reloadIgnoringLocalCache))
        return _fetchAvatarForCurrentUser
    }
}
