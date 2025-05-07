// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGAAnalytics
import MEGAInfrastructure
import MEGAPresentation

public final class OnboardingViewModel: ViewModel<OnboardingViewModel.Route> {
    public enum Route {
        case dataUsageLogin(DataUsageScreenViewModel)
        case login(LoginViewModel)
        case dataUsageSignUp(DataUsageScreenViewModel)
        case signUp(CreateAccountViewModel)
        case loggedIn
    }

    @ViewProperty public var isLoading = true
    @Published var currentPageId: UUID?

    public var isHidden: Bool { isLoading || route?.isLoggedIn == true }

    static let dataUsageCacheKey = "dataUsageDisplayed"

    private var nextRoute: Route?

    private let loginUseCase: any LoginUseCaseProtocol
    private let analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?
    private let permanentCacheService: any CacheServiceProtocol
    private let hasSetupDataUsageNotice: Bool

    public init(
        loginUseCase: some LoginUseCaseProtocol,
        analyticsTracker: (any MEGAAnalyticsTrackerProtocol)?,
        permanentCacheService: some CacheServiceProtocol,
        hasSetupDataUsageNotice: Bool = DependencyInjection.hasSetupDataUsageNotice
    ) {
        self.loginUseCase = loginUseCase
        self.analyticsTracker = analyticsTracker
        self.permanentCacheService = permanentCacheService
        self.hasSetupDataUsageNotice = hasSetupDataUsageNotice
    }

    @MainActor
    public func onAppear() async {
        analyticsTracker?.trackAnalyticsEvent(with: .uspScreenView)

        defer { isLoading = false }

        if await loginUseCase.loginSession() != nil {
            routeTo(.loggedIn)
        }
    }

    func didTapLogin() {
        if shouldDisplayDataUsageNotice() {
            routeTo(.dataUsageLogin(DependencyInjection.dataUsageViewModel))
        } else {
            routeTo(.login(DependencyInjection.loginViewModel))
        }
    }

    func didTapSignUp() {
        analyticsTracker?.trackAnalyticsEvent(with: .signUpButtonOnUSPPagePressed)

        if shouldDisplayDataUsageNotice() {
            routeTo(.dataUsageSignUp(DependencyInjection.dataUsageViewModel))
        } else {
            routeTo(.signUp(DependencyInjection.createAccountViewModel))
        }
    }

    private func shouldDisplayDataUsageNotice() -> Bool {
        hasSetupDataUsageNotice && !dataUsageDisplayed()
    }

    private func dataUsageDisplayed() -> Bool {
        (try? permanentCacheService.fetch(for: Self.dataUsageCacheKey)) ?? false
    }

    public override func bindNewRoute(_ route: Route?) {
        switch route {
        case .dataUsageLogin(let dataUsageViewModel):
            bindDataUsageLoginViewModel(dataUsageViewModel)
        case .login(let loginViewModel):
            bindLoginViewModel(loginViewModel)
        case .dataUsageSignUp(let dataUsageViewModel):
            bindDataUsageSignUpViewModel(dataUsageViewModel)
        case .signUp(let createAccountViewModel):
            bindSignUpViewModel(createAccountViewModel)
        default:
            break
        }
    }

    private func bindDataUsageLoginViewModel(_ viewModel: DataUsageScreenViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                switch route {
                case .dismissed:
                    self?.routeTo(nil)
                case .agreed:
                    self?.routeTo(.login(DependencyInjection.loginViewModel))
                default: break
                }
            }
        }
    }

    private func bindDataUsageSignUpViewModel(_ viewModel: DataUsageScreenViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                switch route {
                case .dismissed:
                    self?.routeTo(nil)
                case .agreed:
                    self?.routeTo(.signUp(DependencyInjection.createAccountViewModel))
                default: break
                }
            }
        }
    }

    private func bindLoginViewModel(_ viewModel: LoginViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                switch route {
                case .signUp:
                    self?.routeTo(.signUp(DependencyInjection.createAccountViewModel))
                case .loggedIn:
                    self?.routeTo(.loggedIn)
                case .dismissed:
                    self?.routeTo(nil)
                default: break
                }
            }
        }
    }

    private func bindSignUpViewModel(_ viewModel: CreateAccountViewModel) {
        bind(viewModel) { [weak self] in
            $0.$route.sink { [weak self] route in
                switch route {
                case .login:
                    self?.routeTo(.login(DependencyInjection.loginViewModel))
                case .dismissed:
                    self?.routeTo(nil)
                case .loggedIn:
                    self?.routeTo(.loggedIn)
                default: break
                }
            }
        }
    }
}

public extension OnboardingViewModel.Route {
    var isLogin: Bool {
        switch self {
        case .login: true
        default: false
        }
    }

    var isSignUp: Bool {
        switch self {
        case .signUp: true
        default: false
        }
    }

    var isLoggedIn: Bool {
        switch self {
        case .loggedIn: true
        default: false
        }
    }

    var isDataUsageLogin: Bool {
        switch self {
        case .dataUsageLogin: true
        default: false
        }
    }

    var isDataUsageSignUp: Bool {
        switch self {
        case .dataUsageSignUp: true
        default: false
        }
    }
}
