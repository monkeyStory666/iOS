// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGAAnalytics
import MEGAAnalyticsMock
import MEGAAuthenticationMocks
import MEGAInfrastructure
import MEGAInfrastructureMocks
import MEGATest
import Testing

struct OnboardingViewModelTests {
    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.route == nil)
        #expect(sut.isLoading)
        #expect(sut.isHidden)
    }

    @Test func onAppear_whenLoginSessionExist_shouldRouteToLoggedIn() async {
        func assert(
            whenLoginSession loginSession: LoginSession?,
            assertion: (SUT) -> Void
        ) async {
            let sut = makeSUT(loginUseCase: MockLoginUseCase(loginSession: loginSession))

            await sut.onAppear()

            assertion(sut)
        }

        await assert(whenLoginSession: nil) { sut in
            #expect(sut.route == nil)
            #expect(sut.isLoading == false)
            #expect(sut.isHidden == false)
        }

        await assert(whenLoginSession: .old) { sut in
            #expect(sut.route?.isLoggedIn == true)
            #expect(sut.isLoading == false)
            #expect(sut.isHidden)
        }

        await assert(whenLoginSession: .renewed) { sut in
            #expect(sut.route?.isLoggedIn == true)
            #expect(sut.isLoading == false)
            #expect(sut.isHidden)
        }
    }

    @Test func onAppear_shouldTrackScreenViewAnalyticsEvent() async {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )

        await sut.onAppear()

        analyticsTracker.swt.assertsEventsEqual(to: [.uspScreenView])
    }

    @Test func didTapLogin_shouldRouteToLogin() {
        let sut = makeSUT()

        sut.didTapLogin()

        #expect(sut.route?.isLogin == true)
    }

    struct ShouldDisplayDataUsageNoticeArguments {
        let hasSetupDataUsageNotice: Bool
        let cacheServiceResult: Result<(any Decodable)?, any Error>
        let shouldDisplayDataUsage: Bool
    }

    @Test(
        arguments: [
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: false,
                cacheServiceResult: .success(true),
                shouldDisplayDataUsage: false
            ),
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: true,
                cacheServiceResult: .success(nil),
                shouldDisplayDataUsage: true
            ),
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: true,
                cacheServiceResult: .success(true),
                shouldDisplayDataUsage: false
            )
        ]
    ) func didTapLogin_shouldRouteToDataUsage(
        arguments: ShouldDisplayDataUsageNoticeArguments
    ) {
        let sut = makeSUT(
            permanentCacheService: MockCacheService(fetch: { key in
                if key == OnboardingViewModel.dataUsageCacheKey {
                    return arguments.cacheServiceResult
                } else {
                    return .failure(ErrorInTest())
                }
            }),
            hasSetupDataUsageNotice: arguments.hasSetupDataUsageNotice
        )

        sut.didTapLogin()

        #expect(sut.route?.isDataUsageLogin == arguments.shouldDisplayDataUsage)
    }

    @Test func didTapSignUp_shouldTrackAnalyticsEvent_andRouteToSignUp() {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker)
        )

        sut.didTapSignUp()

        analyticsTracker.swt.assertsEventsEqual(to: [.signUpButtonOnUSPPagePressed])
        #expect(sut.route?.isSignUp == true)
    }

    @Test(
        arguments: [
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: false,
                cacheServiceResult: .success(true),
                shouldDisplayDataUsage: false
            ),
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: true,
                cacheServiceResult: .success(nil),
                shouldDisplayDataUsage: true
            ),
            ShouldDisplayDataUsageNoticeArguments(
                hasSetupDataUsageNotice: true,
                cacheServiceResult: .success(true),
                shouldDisplayDataUsage: false
            )
        ]
    ) func didTapSignUp_whenShouldDisplayDataUsageNotice_shouldTrackAnalyticsEvent_andRouteToDataUsageSignUp(
        arguments: ShouldDisplayDataUsageNoticeArguments
    ) {
        let analyticsTracker = MockAnalyticsTracking()

        let sut = makeSUT(
            analyticsTracker: MockMegaAnalyticsTracker(tracker: analyticsTracker),
            permanentCacheService: MockCacheService(fetch: { key in
                if key == OnboardingViewModel.dataUsageCacheKey {
                    return arguments.cacheServiceResult
                } else {
                    return .failure(ErrorInTest())
                }
            }),
            hasSetupDataUsageNotice: arguments.hasSetupDataUsageNotice
        )

        sut.didTapSignUp()

        analyticsTracker.swt.assertsEventsEqual(to: [.signUpButtonOnUSPPagePressed])
        #expect(sut.route?.isDataUsageSignUp == arguments.shouldDisplayDataUsage)
    }

    @Test func loginViewModelBindings_shouldRouteCorrectly() {
        func assertWhen(
            loginRoute: LoginViewModel.Route?,
            assertion: (SUT) -> Void
        ) {
            let loginViewModel = DependencyInjection.loginViewModel
            let sut = makeSUT()
            sut.routeTo(.login(loginViewModel))

            loginViewModel.routeTo(loginRoute)

            assertion(sut)
        }

        assertWhen(loginRoute: .dismissed) { sut in
            #expect(sut.route == nil)
        }

        assertWhen(loginRoute: .signUp) { sut in
            #expect(sut.route?.isSignUp == true)
        }
    }

    @Test func loginViewModelBindings_whenLoggedIn_shouldRouteCorrectly() {
        let loginViewModel = DependencyInjection.loginViewModel
        let sut = makeSUT()
        sut.routeTo(.login(loginViewModel))

        loginViewModel.routeTo(.loggedIn)

        #expect(sut.route?.isLoggedIn == true)
    }

    @Test func signUpViewModelBindings_shouldRouteCorrectly() {
        func assertWhen(
            signUpRoute: CreateAccountViewModel.Route?,
            assertion: (SUT) -> Void
        ) {
            let signUpViewModel = DependencyInjection.createAccountViewModel
            let sut = makeSUT()
            sut.routeTo(.signUp(signUpViewModel))

            signUpViewModel.routeTo(signUpRoute)

            assertion(sut)
        }

        assertWhen(signUpRoute: .login) { sut in
            #expect(sut.route?.isLogin == true)
        }

        assertWhen(signUpRoute: .dismissed) { sut in
            #expect(sut.route == nil)
        }

        assertWhen(signUpRoute: .loggedIn) { sut in
            #expect(sut.route?.isLoggedIn == true)
        }
    }

    @Test func dataUsageLoginBindings_shouldRouteCorrectly() {
        func assertWhen(
            route: DataUsageScreenViewModel.Route?,
            assertion: (SUT) -> Void
        ) {
            let dataUsageScreenViewModel = DependencyInjection.dataUsageViewModel
            let sut = makeSUT()
            sut.routeTo(.dataUsageLogin(dataUsageScreenViewModel))

            dataUsageScreenViewModel.routeTo(route)

            assertion(sut)
        }

        assertWhen(route: .dismissed) { sut in
            #expect(sut.route == nil)
        }

        assertWhen(route: .agreed) { sut in
            #expect(sut.route?.isLogin == true)
        }
    }

    @Test func dataUsageSignUpBindings_shouldRouteCorrectly() {
        func assertWhen(
            route: DataUsageScreenViewModel.Route?,
            assertion: (SUT) -> Void
        ) {
            let dataUsageScreenViewModel = DependencyInjection.dataUsageViewModel
            let sut = makeSUT()
            sut.routeTo(.dataUsageSignUp(dataUsageScreenViewModel))

            dataUsageScreenViewModel.routeTo(route)

            assertion(sut)
        }

        assertWhen(route: .dismissed) { sut in
            #expect(sut.route == nil)
        }

        assertWhen(route: .agreed) { sut in
            #expect(sut.route?.isSignUp == true)
        }
    }

    // MARK: - Test Helpers

    private typealias SUT = OnboardingViewModel

    private func makeSUT(
        loginUseCase: some LoginUseCaseProtocol = MockLoginUseCase(),
        analyticsTracker: some MEGAAnalyticsTrackerProtocol = MockMegaAnalyticsTracker(tracker: MockAnalyticsTracking()),
        permanentCacheService: some CacheServiceProtocol = MockCacheService(),
        hasSetupDataUsageNotice: Bool = false
    ) -> SUT {
        OnboardingViewModel(
            loginUseCase: loginUseCase,
            analyticsTracker: analyticsTracker,
            permanentCacheService: permanentCacheService,
            hasSetupDataUsageNotice: hasSetupDataUsageNotice
        )
    }
}
