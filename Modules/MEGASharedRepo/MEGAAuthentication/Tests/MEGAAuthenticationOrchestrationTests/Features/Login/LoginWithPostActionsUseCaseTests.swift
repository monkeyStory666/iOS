import MEGAAuthentication
import MEGAAuthenticationMocks
import MEGAAuthenticationOrchestration
import Testing

struct LoginWithPostActionsUseCaseTests {
    
    @Test("when login with user name and password should perform post login actions",
          arguments: [("user", "password")])
    func loginUserNameAndPassword(userName: String, password: String) async throws {
        let loginUseCase = MockLoginUseCase()
        let postLoginAction = MockPostLoginAction()
        let sut = LoginWithPostActionsUseCaseTests
            .makeSUT(
                loginUseCase: loginUseCase,
                postLoginActions: [postLoginAction])
        
        try await sut.login(with: userName, and: password)
        
        #expect(loginUseCase.actions == [.login(
            username: userName, password: password)])
        #expect(await postLoginAction.postLoginCalledCount == 1)
    }
    
    @Test("when login with user name, password and pin should perform post login actions",
          arguments: [("user", "password", "pin")])
    func loginUserNamePasswordAndPin(userName: String, password: String, pin: String) async throws {
        let loginUseCase = MockLoginUseCase()
        let postLoginAction = MockPostLoginAction()
        let sut = LoginWithPostActionsUseCaseTests
            .makeSUT(
                loginUseCase: loginUseCase,
                postLoginActions: [postLoginAction])
        
        try await sut.login(with: userName, and: password, pin: pin)
        
        #expect(loginUseCase.actions == [.twoFactorLogin(
            username: userName, password: password, pin: pin)])
        #expect(await postLoginAction.postLoginCalledCount == 1)
    }
    
    private static func makeSUT(
        loginUseCase: some LoginUseCaseProtocol = MockLoginUseCase(),
        postLoginActions: [any PostLoginAction] = []
    ) -> LoginWithPostActionsUseCase {
        .init(
            loginUseCase: loginUseCase,
            postLoginActions: postLoginActions)
    }
}

private actor MockPostLoginAction: PostLoginAction {
    var postLoginCalledCount = 0
    
    func handlePostLogin() async throws {
        postLoginCalledCount += 1
    }
}
