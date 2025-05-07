// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

/// Determines if the provided error matches a specific error type and case.
///
/// This function is a workaround for unit testing scenarios where specific error types
/// and cases are not caught properly by the standard `catch` blocks. It performs
/// a string comparison to check if the error's type and description match the
/// specified error type and case.
///
/// - Parameters:
///   - error: The error to evaluate. This is typically caught in a catch block.
///   - errorType: A string representing the expected type of the error.
///                This should match the name of the error type.
///   - errorCase: A string representing the specific case of the error type
///                that needs to be matched.
///
/// - Returns: A Boolean value indicating whether the error matches the specified type and case.
///
/// Usage Example:
/// ```
/// do {
///     try await accountConfirmationUseCase.resendSignUpLink(withEmail: email, name: name)
///     onSuccess?(email)
/// } catch ResendSignupLinkError.emailAlreadyInUse {
///     presentEmailAlreadyInUse() // This does not work in unit test
/// } catch {
///     if isError(error, ofType: "ResendSignupLinkError", case: "emailAlreadyInUse") {
///         presentEmailAlreadyInUse() // This works in unit tests
///     }
/// }
/// ```
@available(
    *, deprecated,
     renamed: "isError(_:equalTo:)",
     message: "This function is deprecated to avoid use of raw strings, please use the new function `isError(_:equalTo:)`"
)
public func isError(_ error: any Error, ofType errorType: String, case errorCase: String) -> Bool {
    String(describing: type(of: error)) == errorType
        && stringCase(for: error) == errorCase
}

/// Determines if the provided error matches a specific error type.
///
/// This function is useful for scenarios where only the type of the error
/// is important, not the specific case or associated values.
///
/// - Parameters:
///   - error: The error to evaluate. This is typically caught in a catch block.
///   - errorType: The type of error to compare against.
///
/// - Returns: A Boolean value indicating whether the error matches the specified type.
///
/// Usage Example:
/// ```
/// do {
///     try await accountConfirmationUseCase.resendSignUpLink(withEmail: email, name: name)
///     onSuccess?(email)
/// } catch {
///     if isError(error, ofType: ResendSignupLinkError.self) {
///         presentEmailAlreadyInUse()
///     }
/// }
/// ```
public func isError(_ error: any Error, ofType errorType: (any Error.Type)) -> Bool {
    String(describing: type(of: error)) == String(describing: errorType)
}

/// Determines if the provided error matches a specific error type and case.
///
/// This function is a workaround for unit testing scenarios where specific error types
/// and cases are not caught properly by the standard `catch` blocks. It performs
/// a string comparison to check if the error's type and description match the
/// specified error type and case.
///
/// - Parameters:
///   - error: The error to evaluate. This is typically caught in a catch block.
///   - otherError: The error type and case to compare with.
///
/// - Returns: A Boolean value indicating whether the error matches the specified type and case.
///
/// Usage Example:
/// ```
/// do {
///     try await accountConfirmationUseCase.resendSignUpLink(withEmail: email, name: name)
///     onSuccess?(email)
/// } catch ResendSignupLinkError.emailAlreadyInUse {
///     presentEmailAlreadyInUse() // This does not work in unit test
/// } catch {
///     if isError(error, isEqualTo: ResendSignupLinkError.emailAlreadyInUse) {
///         presentEmailAlreadyInUse() // This works in unit tests
///     }
/// }
/// ```
///
/// Notes:
/// I tried adding this in an extension for `Error` type so that the interface can look like `error.isEqualTo(otherError)`.
/// But the unit tests still fails when I do that. I'm not sure why exactly that happens but for now this should be good enough.
public func isError(_ error: any Error, equalTo otherError: any Error) -> Bool {
    String(describing: type(of: error)) == String(describing: type(of: otherError))
        && stringCase(for: error) == stringCase(for: otherError)
}

/// Get the case name of an Error case excluding the associated values
private func stringCase(for error: any Error) -> String {
    String(describing: error)
        .components(separatedBy: "(")
        .first ?? ""
}
