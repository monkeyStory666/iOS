// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAnalytics
import MEGAAuthentication
import MEGAConnectivity
import MEGAInfrastructure
import MEGAPresentation
import MEGASharedRepoL10n
import MEGASwift

public protocol OffboardingUseCaseProtocol {
    func activeLogout(timeout: TimeInterval?) async
    func forceLogout(timeout: TimeInterval?) async
    func startOffboardingPublisher() -> AnyPublisher<Void, Never>
}

public extension OffboardingUseCaseProtocol {
    static var defaultTimeout: TimeInterval { 8 }

    func activeLogout() async {
        await activeLogout(timeout: Self.defaultTimeout)
    }

    func forceLogout() async {
        await forceLogout(timeout: Self.defaultTimeout)
    }
}

public final class OffboardingUseCase: OffboardingUseCaseProtocol {
    private let startOffboardingSubject = PassthroughSubject<Void, Never>()

    private let loginAPIRepository: any LoginAPIRepositoryProtocol
    private let loginStoreRepository: any LoginStoreRepositoryProtocol
    private let appLoadingManager: any AppLoadingStateManagerProtocol
    private let passwordReminderUseCase: any PasswordReminderUseCaseProtocol
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let connectionUseCase: any ConnectionUseCaseProtocol
    private let snackbarDisplayer: any SnackbarDisplaying

    private let preLogoutAction: (() async -> Void)?
    private let postLogoutAction: (() async -> Void)?

    public init(
        loginAPIRepository: some LoginAPIRepositoryProtocol,
        loginStoreRepository: some LoginStoreRepositoryProtocol,
        appLoadingManager: some AppLoadingStateManagerProtocol,
        passwordReminderUseCase: some PasswordReminderUseCaseProtocol,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?,
        connectionUseCase: some ConnectionUseCaseProtocol,
        snackbarDisplayer: any SnackbarDisplaying,
        preLogoutAction: (() async -> Void)?,
        postLogoutAction: (() async -> Void)?
    ) {
        self.loginAPIRepository = loginAPIRepository
        self.loginStoreRepository = loginStoreRepository
        self.appLoadingManager = appLoadingManager
        self.passwordReminderUseCase = passwordReminderUseCase
        self.analyticsTracker = analyticsTracker
        self.connectionUseCase = connectionUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.preLogoutAction = preLogoutAction
        self.postLogoutAction = postLogoutAction
    }

    public func activeLogout(timeout: TimeInterval?) async {
        guard connectionUseCase.isConnected else {
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.NoInternetConnection.label
            ))
            return
        }

        analyticsTracker?.trackAnalyticsEvent(with: .logoutButtonPressed)

        if let showPasswordReminder = try? await passwordReminderUseCase.shouldShowPasswordReminder(
            atLogout: true
        ), showPasswordReminder == false {
            await forceLogout(timeout: timeout)
        } else {
            startOffboardingSubject.send(())
        }
    }
    
    public func forceLogout(timeout: TimeInterval?) async {
        appLoadingManager.startLoading(.init(
            blur: true,
            allowUserInteraction: false
        ))
        await preLogoutAction?()

        await logout(timeout: timeout)

        await postLogoutAction?()
        appLoadingManager.stopLoading()
    }

    public func startOffboardingPublisher() -> AnyPublisher<Void, Never> {
        startOffboardingSubject.eraseToAnyPublisher()
    }

    private func logout(timeout: TimeInterval?) async {
        if let timeout {
            try? await withTimeout(seconds: timeout) { [weak self] in
                await self?.logout()
            }
        } else {
            await logout()
        }
    }

    private func logout() async {
        try? loginStoreRepository.delete()

        await loginAPIRepository.logout()

        loginAPIRepository.set(accountAuth: nil)
    }
}
