#if !targetEnvironment(macCatalyst)
public protocol AnalyticsEventEntityProtocol: Equatable {
    var identifier: (any EventIdentifier)? { get }
    var rawValue: String { get }
}
#else
public protocol AnalyticsEventEntityProtocol: Equatable {
    var rawValue: String { get }
}
#endif

public extension AnalyticsEventEntityProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

// This enum and MEGAAnalyticsTrackerProtocol should be exposed to both iOS and macOS app
public enum AnalyticsEventEntity: String {
    // ScreenView events
    case uspScreenView
    case signupScreenView
    case loginScreenView
    case multiFactorAuthScreenView
    case emailConfirmationScreenView
    case homeScreenView
    case settingsScreenView
    case subscriptionScreenView
    case subscriptionSuccessScreenView
    case termsOfServiceScreenView
    case passwordReminderScreenView
    case testPasswordScreenView
    case recoveryKeyScreenView
    case unsupportedPlanScreenView
    case cancelSurveyScreenView
    case debugLogsScreenView

    // Button pressed events
    case signupButtonOnLoginPagePressed
    case signUpButtonOnUSPPagePressed
    case createAccountButtonPressed
    case resendEmailConfirmationButtonPressed
    case loginButtonPressed
    case subscribeButtonPressed
    case homeBannerSubscribeButtonPressed
    case settingsBannerSubscribeButtonPressed
    case logoutButtonPressed
    case termsOfServiceCloseButtonPressed
    case unsupportedPlanLabelButtonPressed
    case startFreeTrialButtonPressed
    case cancelSurveySkipButtonPressed
    case cancelSurveyCloseButtonPressed
    case cancelSurveyDontCancelButtonPressed
    case cancelSurveyContinueButtonPressed
    case whatsNewScreenPrimaryButtonPressed
    case whatsNewScreenSecondaryButtonPressed
    case submitDebugLogsButtonPressed

    // General events
    case accountActivated
    case multiFactorAuthSuccessful
    case multiFactorAuthFailed
    case subscribeSuccessful
    case subscribeFailed
    case subscribeCancelled
    case debugLogsEnabled
    case debugLogsDisabled
}

public protocol MEGAAnalyticsTrackerProtocol {
    func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol)
}

public extension MEGAAnalyticsTrackerProtocol {
    func trackAnalyticsEvent(with event: AnalyticsEventEntity) {
        let anyEvent: any AnalyticsEventEntityProtocol = event
        trackAnalyticsEvent(with: anyEvent)
    }
}

// Currently, our KMM Analytics library (MEGAAnalyticsiOS) doesn't have suppport for macOS
// So the concrete implementation is hidden and the analytics will actually be triggered only from iOS
#if !targetEnvironment(macCatalyst)
import MEGAAnalyticsiOS

extension AnalyticsEventEntity: AnalyticsEventEntityProtocol {
    public var identifier: (any EventIdentifier)? {
        switch self {
        // ScreenView Events
        case .uspScreenView:
            return USPScreenEvent()
        case .signupScreenView:
            return SignUpScreenEvent()
        case .loginScreenView:
            return LoginScreenEvent()
        case .multiFactorAuthScreenView:
            return MultiFactorAuthScreenEvent()
        case .emailConfirmationScreenView:
            return EmailConfirmationScreenEvent()
        case .homeScreenView:
            return HomeScreenEvent()
        case .settingsScreenView:
            return SettingsScreenEvent()
        case .subscriptionScreenView:
            return SubscriptionScreenEvent()
        case .subscriptionSuccessScreenView:
            return SubscriptionSuccessScreenEvent()
        case .termsOfServiceScreenView:
            return TermsOfServiceScreenEvent()
        case .passwordReminderScreenView:
            return PasswordReminderScreenEvent()
        case .testPasswordScreenView:
            return TestPasswordScreenEvent()
        case .recoveryKeyScreenView:
            return RecoveryKeyScreenEvent()
        case .unsupportedPlanScreenView:
            return BusinessUserRestrictionsScreenEvent()
        case .unsupportedPlanLabelButtonPressed:
            return BusinessRestrictionsBannerActionButtonPressedEvent()
        case .cancelSurveyScreenView:
            return SubscriptionCancellationSurveyScreenEvent()
        case .debugLogsScreenView:
            return DebugLogsScreenEvent()

        // Button Pressed Events
        case .signupButtonOnLoginPagePressed:
            return SignUpButtonOnLoginPagePressedEvent()
        case .signUpButtonOnUSPPagePressed:
            return SignUpButtonOnUSPPagePressedEvent()
        case .createAccountButtonPressed:
            return CreateAccountButtonPressedEvent()
        case .resendEmailConfirmationButtonPressed:
            return ResendEmailConfirmationButtonPressedEvent()
        case .loginButtonPressed:
            return LoginButtonPressedEvent()
        case .subscribeButtonPressed:
            return SubscribeButtonPressedEvent()
        case .homeBannerSubscribeButtonPressed:
            return SubscribeButtonHomeBannerPressedEvent()
        case .settingsBannerSubscribeButtonPressed:
            return SubscribeButtonSettingsBannerPressedEvent()
        case .logoutButtonPressed:
            return LogoutButtonPressedEvent()
        case .termsOfServiceCloseButtonPressed:
            return TermsOfServiceCloseButtonPressedEvent()
        case .startFreeTrialButtonPressed:
            return StartFreeTrialButtonPressedEvent()
        case .cancelSurveySkipButtonPressed:
            return SkipCancellationSurveyButtonPressedEvent()
        case .cancelSurveyCloseButtonPressed:
            return SubscriptionCancellationSurveyCancelViewButtonEvent()
        case .cancelSurveyDontCancelButtonPressed:
            return SubscriptionCancellationSurveyDontCancelButtonEvent()
        case .cancelSurveyContinueButtonPressed:
            return SubscriptionCancellationSurveyCancelSubscriptionButtonEvent()
        case .whatsNewScreenPrimaryButtonPressed:
            return PromotionalSheetPrimaryButtonPressedEvent()
        case .whatsNewScreenSecondaryButtonPressed:
            return PromotionalSheetSecondaryButtonPressedEvent()
        case .submitDebugLogsButtonPressed:
            return SubmitDebugLogsButtonPressedEvent()

        // General Events
        case .accountActivated:
            return AccountActivatedEvent()
        case .multiFactorAuthSuccessful:
            return MultiFactorAuthVerificationSuccessEvent()
        case .multiFactorAuthFailed:
            return MultiFactorAuthVerificationFailedEvent()
        case .subscribeSuccessful:
            return SubscriptionSuccessfulEvent()
        case .subscribeFailed:
            return SubscriptionFailedEvent()
        case .subscribeCancelled:
            return SubscriptionCancelledEvent()
        case .debugLogsEnabled:
            return DebugLogsEnabledEvent()
        case .debugLogsDisabled:
            return DebugLogsDisabledEvent()
        }
    }
}

public struct MEGAAnalyticsTracker: MEGAAnalyticsTrackerProtocol {
    private let tracker: any AnalyticsTracking
    private let checkEnabledUseCase: any CheckAnalyticsEnabledUseCaseProtocol

    public init(
        from source: AnalyticsSource,
        checkEnabledUseCase: some CheckAnalyticsEnabledUseCaseProtocol = DependencyInjection.checkAnalyticsEnabledUseCase
    ) {
        self.tracker = Tracker.shared(for: source)
        self.checkEnabledUseCase = checkEnabledUseCase
    }

    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        guard checkEnabledUseCase.isAnalyticsEnabled() else { return }

        tracker.trackAnalyticsEvent(with: event)
    }
}
#else
extension AnalyticsEventEntity: AnalyticsEventEntityProtocol {}

public struct MEGACatalystAnalyticsTracker: MEGAAnalyticsTrackerProtocol {
    public init() {}

    public func trackAnalyticsEvent(with event: some AnalyticsEventEntityProtocol) {
        // do nothing
    }
}
#endif
