// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import MEGAPresentation
import MEGAAuthentication
import MEGAUIComponent

public final class DeleteAccountDetailsViewModel: ViewModel<DeleteAccountDetailsViewModel.Route> {
    public enum Route {
        case dismissed
        case twoFactorAuthentication(MEGAAuthentication.TwoFactorAuthenticationViewModel)
        case emailSent(DeleteAccountEmailSentViewModel)
    }

    @ViewProperty var sections: [DeleteAccountDetailsSectionViewModel]
    @ViewProperty var buttonState: MEGAButtonStyle.State = .default

    private let deleteAccountUseCase: any DeleteAccountUseCaseProtocol
    private let fetchAccountPlanUseCase: any FetchAccountPlanUseCaseProtocol

    private var pin: String?
    private var deleteAccountEmailSentViewModel: DeleteAccountEmailSentViewModel {
        DeleteAccountEmailSentViewModel(
            pin: pin,
            deleteAccountUseCase: deleteAccountUseCase,
            snackbarDisplayer: MEGAAuthentication.DependencyInjection.snackbarDisplayer
        )
    }

    public init(
        sections: [DeleteAccountDetailsSectionViewModel],
        deleteAccountUseCase: some DeleteAccountUseCaseProtocol = DependencyInjection.deleteAccountUseCase,
        fetchAccountPlanUseCase: some FetchAccountPlanUseCaseProtocol = DependencyInjection.fetchAccountPlanUseCase
    ) {
        self.sections = sections
        self.deleteAccountUseCase = deleteAccountUseCase
        self.fetchAccountPlanUseCase = fetchAccountPlanUseCase
        super.init()
    }

    public func onAppear() async throws {
        try await fetchSubscription()
    }

    public func didTapClose() {
        routeTo(.dismissed)
    }

    public func didTapContinue() async {
        await deleteAccount()
    }

    public func didTapDontDelete() {
        routeTo(.dismissed)
    }

    // MARK: - Private

    private func fetchSubscription() async throws {
        let accountDetails = try await fetchAccountPlanUseCase.fetchAccountDetails()

        let featurePlanSubscriptionSections = makeFeaturePlanSubscriptionSections(
            from: accountDetails,
            using: sections
        )

        sections += featurePlanSubscriptionSections

        let isUserInProPlan = accountDetails.accountPlan?.isProPlan ?? false

        guard isUserInProPlan else {
            return
        }

        let proPlanSubscriptionPlatform = try await deleteAccountUseCase.fetchSubscriptionPlatform()

        let proPlanSubscriptionSection = makeProPlanSubscriptionSection(
            from: proPlanSubscriptionPlatform,
            using: sections
        )

        if let proPlanSubscriptionSection {
            sections += [proPlanSubscriptionSection]
        }
    }

    private func makeFeaturePlanSubscriptionSections(
        from accountDetails: AccountDetailsEntity,
        using currentSections: [DeleteAccountDetailsSectionViewModel]
    ) -> [DeleteAccountDetailsSectionViewModel] {
        let paymentMethods = Set(accountDetails.subscriptions.map(\.paymentMethod))

        guard paymentMethods.isNotEmpty else {
            return []
        }

        return paymentMethods.compactMap { paymentMethod in
            switch paymentMethod {
            case .appleAppStore where !currentSections.contains(.appleSubscription):
                .appleSubscription
            case .googlePlayStore where !currentSections.contains(.androidSubscription):
                .androidSubscription
            case .webClient where !currentSections.contains(.otherPlatformSubscription):
                .otherPlatformSubscription
            default:
                nil
            }
        }
    }

    private func makeProPlanSubscriptionSection(
        from subscriptionPlatform: SubscriptionPlatform,
        using currentSections: [DeleteAccountDetailsSectionViewModel]
    ) -> DeleteAccountDetailsSectionViewModel? {
        let newSection: [DeleteAccountDetailsSectionViewModel] = switch subscriptionPlatform {
        case .apple where !currentSections.contains(.appleSubscription):
            [.appleSubscription]
        case .android where !currentSections.contains(.androidSubscription):
           [.androidSubscription]
        case .other where !currentSections.contains(.otherPlatformSubscription):
            [.otherPlatformSubscription]
        default:
            []
        }

        return newSection.first
    }

    private func deleteAccount(with pin: String? = nil) async {
        self.pin = pin
        buttonState = .load

        defer { buttonState = .default }

        do {
            try await deleteAccountUseCase.deleteAccount(with: pin)

            if case .twoFactorAuthentication = route {
                routeTo(nil)
                // Wait for 2FA screen to dismiss before showing the delete account
                try await Task.sleep(nanoseconds: 600_000_000)
            }

            routeTo(.emailSent(deleteAccountEmailSentViewModel))
        } catch {
            if case DeleteAccountRepository.Error.twoFactorAuthenticationRequired = error {
                showTwoFAScreen()
            } else if case DeleteAccountRepository.Error.wrongPin = error, case .twoFactorAuthentication(let viewModel) = route {
                await viewModel.didVerifyWithWrongPasscode()
            }
        }
    }

    override public func bindNewRoute(_ route: Route?) {
        switch route {
        case let .twoFactorAuthentication(twoFactorAuthViewModel):
            bindTwoFactorAuthViewModel(twoFactorAuthViewModel)
        case let .emailSent(deleteAccountEmailSentViewModel):
            bindEmailSentViewModel(deleteAccountEmailSentViewModel)
        default:
            break
        }
    }

    private func bindTwoFactorAuthViewModel(_ viewModel: TwoFactorAuthenticationViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self else { return }

                switch route {
                case let .verify(pin):
                    Task { [weak self] in
                        guard let self else { return }
                        await deleteAccount(with: pin)
                    }
                case .dismissed:
                    routeTo(nil)
                default:
                    break
                }
            }
        }
    }

    private func bindEmailSentViewModel(_ viewModel: DeleteAccountEmailSentViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                guard let self else { return }

                switch route {
                case .dismissed:
                    routeTo(.dismissed)
                default:
                    break
                }
            }
        }
    }

    private func showTwoFAScreen() {
        routeTo(.twoFactorAuthentication(MEGAAuthentication.DependencyInjection.twoFactorAuthenticationViewModel))
    }
}

extension DeleteAccountDetailsViewModel.Route {
    var hasDismissed: Bool {
        if case .dismissed = self {
            return true
        } else {
            return false
        }
    }

    var isEmailSent: Bool {
        switch self {
        case .emailSent: true
        default: false
        }
    }
}
