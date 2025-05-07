import Foundation

/// A concrete implementation of the `DeeplinkHandling` protocol that checks for a specific query parameter in a URL.
///
/// `SpecificQueryHandler` is designed to be used as a component (or child handler) within a composite deeplink builder.
/// It inspects the URL's query parameters and, if the specified query key is present, invokes a provided handler closure.
///
/// For an example of its usage, refer to the `testDeepLinkWithMultipleChildHandlers` unit test in `MEGADeeplinkHandlingTests`.
public struct SpecificQueryHandler: DeeplinkHandling {
    /// The query key that this handler looks for in the URL's query parameters.
    private let queryKey: String
    /// The closure to execute when the URL contains the specified query key.
    private let handler: (URL) -> Void

    /// Creates a new instance of `SpecificQueryHandler`.
    ///
    /// - Parameters:
    ///   - queryKey: The key to search for in the URL's query parameters.
    ///   - handler: A closure that is executed when the URL contains the specified query key.
    public init(queryKey: String, handler: @escaping (URL) -> Void) {
        self.queryKey = queryKey
        self.handler = handler
    }

    /// Determines whether the given URL can be handled by this handler.
    ///
    /// This method checks if the URL's query items contain the specified query key.
    ///
    /// - Parameter url: The URL to be evaluated.
    /// - Returns: `true` if the URL contains the query key; otherwise, `false`.
    public func canHandle(_ url: URL) -> Bool {
        return url.queryItems.keys.contains(queryKey)
    }

    /// Handles the given URL by executing the provided handler closure.
    ///
    /// - Parameter url: The URL to be processed.
    public func handle(_ url: URL) {
        handler(url)
    }
}
