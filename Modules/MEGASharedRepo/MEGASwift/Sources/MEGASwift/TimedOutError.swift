import Foundation

/**
 An error type representing a timeout.

 Use this error to indicate that an operation has timed out.
 */
public struct TimedOutError: Error {
    /// Creates a new `TimedOutError` instance.
    public init() {}
}

/**
 An extension to `Error` providing a convenience property to check for timeout errors.

 The `isTimeoutError` property uses a helper function `isError(_:equalTo:)` (assumed to be defined elsewhere)
 to determine whether the error is equal to a `TimedOutError`.
 */
public extension Error {
    /// A Boolean value indicating whether the error is a timeout error.
    var isTimeoutError: Bool {
        isError(self, equalTo: TimedOutError())
    }
}
