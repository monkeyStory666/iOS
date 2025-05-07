// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGASDKRepo
import Combine
import Testing
import MEGATest

struct ChangeSDKEnvironmentUseCaseTests {
    @Test(
        arguments: [
            SDKEnvironment.production,
            SDKEnvironment.staging
        ]
    ) func setSDKEnvironment_shouldCallRepository_thenRefreshSession(
        environment: SDKEnvironment
    ) async {
        let mockRepo = MockChangeSDKEnvironmentRepository()

        let sut = makeSUT(repository: mockRepo)

        sut.setSDKEnvironment(environment)

        mockRepo.swt.assertActions(shouldBe: [.setSDKEnvironment(environment)])
    }

    // MARK: - Test Helpers

    private func makeSUT(
        repository: any ChangeSDKEnvironmentRepositoryProtocol = MockChangeSDKEnvironmentRepository(),
        line: UInt = #line
    ) -> ChangeSDKEnvironmentUseCase {
        ChangeSDKEnvironmentUseCase(
            repository: repository
        )
    }
}

final class MockChangeSDKEnvironmentRepository:
    MockObject<MockChangeSDKEnvironmentRepository.Action>,
    ChangeSDKEnvironmentRepositoryProtocol {
    enum Action: Equatable {
        case setSDKEnvironment(SDKEnvironment)
    }

    func setSDKEnvironment(_ environment: SDKEnvironment) {
        actions.append(.setSDKEnvironment(environment))
    }
}
