import MEGAAuthentication

public protocol PostLoginAction: Sendable {
    func handlePostLogin() async throws
}
 
public struct LoginWithPostActionsUseCase: LoginUseCaseProtocol {
    private let loginUseCase: any LoginUseCaseProtocol
    private let postLoginActions: [any PostLoginAction]
     
    public init(
        loginUseCase: any LoginUseCaseProtocol,
        postLoginActions: [any PostLoginAction]
    ) {
        self.loginUseCase = loginUseCase
        self.postLoginActions = postLoginActions
    }
     
    public func login(with username: String, and password: String) async throws {
        try await loginUseCase.login(with: username, and: password)
        try await handlePostLoginActions()
    }
     
    public func login(with username: String, and password: String, pin: String) async throws {
        try await loginUseCase.login(with: username, and: password, pin: pin)
        try await handlePostLoginActions()
    }
     
    public func loginSession() async -> LoginSession? {
        await loginUseCase.loginSession()
    }
     
    public func hasLoggedIn() -> Bool {
        loginUseCase.hasLoggedIn()
    }
     
    public func resendVerificationEmail() {
        loginUseCase.resendVerificationEmail( )
    }
     
    private func handlePostLoginActions() async throws {
        for action in postLoginActions {
            try await action.handlePostLogin()
        }
    }
}
