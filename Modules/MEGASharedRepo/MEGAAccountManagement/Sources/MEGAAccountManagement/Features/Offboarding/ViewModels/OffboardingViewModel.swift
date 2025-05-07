// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAnalytics
import MEGAConnectivity
import MEGASharedRepoL10n
import MEGAPresentation

public final class OffboardingViewModel: NoRouteViewModel, @unchecked Sendable {
    @ViewProperty var isPresented: Bool = false

    private let connectionUseCase: ConnectionUseCaseProtocol
    private let snackbarDisplayer: SnackbarDisplaying
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let offboardingUseCase: any OffboardingUseCaseProtocol

    public init(
        connectionUseCase: ConnectionUseCaseProtocol = MEGAConnectivity.DependencyInjection
            .singletonConnectionUseCase,
        snackbarDisplayer: SnackbarDisplaying = DependencyInjection
            .snackbarDisplayer,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)? = DependencyInjection.analyticsTracker,
        offboardingUseCase: any OffboardingUseCaseProtocol
    ) {
        self.connectionUseCase = connectionUseCase
        self.snackbarDisplayer = snackbarDisplayer
        self.analyticsTracker = analyticsTracker
        self.offboardingUseCase = offboardingUseCase
        super.init()

        offboardingUseCase.startOffboardingPublisher()
            .sink { [weak self] in
                self?.isPresented = true
            }
            .store(in: &cancellables)
    }

    public func didClose() {
        isPresented = false
    }

    public func didProceedToLogout(
        with prelogoutHandler: () async -> Void = {}
    ) async {
        guard connectionUseCase.isConnected else {
            snackbarDisplayer.display(.init(
                text: SharedStrings.Localizable.NoInternetConnection.label
            ))
            return
        }

        analyticsTracker?.trackAnalyticsEvent(with: .logoutButtonPressed)

        await prelogoutHandler()
        await offboardingUseCase.forceLogout()
        isPresented = false
    }
}
