import Foundation

/// A protocol that defines a handler for processing deep links.
///
/// Conforming types inspect a URL to determine whether they can handle it and perform the associated action.
public protocol DeeplinkHandling {
    /// Determines if the handler is able to process the given URL.
    ///
    /// - Parameter url: The URL to be evaluated.
    /// - Returns: `true` if the handler can process the URL; otherwise, `false`.
    func canHandle(_ url: URL) -> Bool

    /// Processes the given URL.
    ///
    /// This method is called only if `canHandle(_:)` returns `true`.
    ///
    /// - Parameter url: The URL to handle.
    func handle(_ url: URL)
}
