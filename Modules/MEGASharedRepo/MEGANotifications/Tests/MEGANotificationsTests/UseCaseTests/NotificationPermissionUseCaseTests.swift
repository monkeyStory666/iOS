// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGANotifications
@testable import MEGANotificationsMocks
import Testing
import UserNotifications
import MEGASwift
import MEGATest

struct NotificationPermissionUseCaseTests {
    @Test func requestPermission_shouldRequestPermissionFromRequester() async throws {
        let requester = MockNotificationPermissionRequester()
        let sut = makeSUT(notificationRequester: requester)

        try await sut.requestPermission()
        requester.swt.assert(
            .requestAuthorization(option: [.alert, .badge, .sound]),
            isCalled: .once
        )
    }

    @Test func requestPermission_whenRequesterFails_shouldThrowError() async {
        let requester = MockNotificationPermissionRequester(requestAuthorization: .failure(ErrorInTest()))
        let sut = makeSUT(notificationRequester: requester)

        await #expect(
            performing: { try await sut.requestPermission() },
            throws: { isError($0, equalTo: ErrorInTest()) }
        )
    }

    @Test func requestPermission_whenRequesterReturnFalse_shouldThrowNotGranted() async {
        let requester = MockNotificationPermissionRequester(requestAuthorization: .success(false))
        let sut = makeSUT(notificationRequester: requester)

        await #expect(
            performing: { try await sut.requestPermission() },
            throws: { ($0 as? NotificationPermissionUseCase.Error) == .notGranted }
        )
    }

    struct HasPermissionArguments {
        let uuid = UUID()
        let authorizationStatus: UNAuthorizationStatus
        let expectedResult: Bool
    }

    @Test(
        arguments: [
            HasPermissionArguments(
                authorizationStatus: .authorized,
                expectedResult: true
            ),
            HasPermissionArguments(
                authorizationStatus: .denied,
                expectedResult: false
            ),
            HasPermissionArguments(
                authorizationStatus: .notDetermined,
                expectedResult: false
            )
        ]
    ) func hasPermission(
        arguments: HasPermissionArguments
    ) async {
        let requester = MockNotificationPermissionRequester(
            authorizationStatus: arguments.authorizationStatus
        )
        let sut = makeSUT(notificationRequester: requester)

        let result = await sut.hasPermission()

        #expect(result == arguments.expectedResult)
        requester.swt.assert(.authorizationStatus, isCalled: .once)
    }

    struct StatusArguments {
        let uuid = UUID()
        let authorizationStatus: UNAuthorizationStatus
        let expectedResult: NotificationPermissionStatus
    }

    @Test(
        arguments: [
            StatusArguments(
                authorizationStatus: .authorized,
                expectedResult: .authorized
            ),
            StatusArguments(
                authorizationStatus: .ephemeral,
                expectedResult: .authorized
            ),
            StatusArguments(
                authorizationStatus: .provisional,
                expectedResult: .authorized
            ),
            StatusArguments(
                authorizationStatus: .denied,
                expectedResult: .denied
            ),
            StatusArguments(
                authorizationStatus: .notDetermined,
                expectedResult: .notDetermined
            )
        ]
    ) func status_shouldReturnMappedStatus(arguments: StatusArguments) async {
        let sut = makeSUT(
            notificationRequester: MockNotificationPermissionRequester(
                authorizationStatus: arguments.authorizationStatus
            )
        )

        let result = await sut.status()

        #expect(result == arguments.expectedResult)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        notificationRequester: NotificationPermissionRequesting = MockNotificationPermissionRequester()
    ) -> NotificationPermissionUseCase {
        NotificationPermissionUseCase(notificationRequester: notificationRequester)
    }
}
