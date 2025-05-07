import SwiftUI
import MEGAUIComponent

public protocol LoginContentViewModelProtocol: ObservableObject {
    var username: String { get set }
    var password: String { get set }
    var shouldSecurePassword: Bool { get set }
    var usernameFieldState: FieldState { get }
    var passwordFieldState: FieldState { get }
    var buttonState: MEGAButtonStyle.State { get }
    var shouldShowSignUpButton: Bool { get }
    var errorBannerSubtitle: String? { get }
    func didTapLogin() async
    func didTapSignUp()
}
