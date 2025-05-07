import Foundation

/// An extension to `URL` that provides a convenient computed property for accessing query parameters.
public extension URL {
    /// A dictionary containing the query parameters of the URL.
    ///
    /// This computed property uses `URLComponents` to parse the URL and extract its query items.
    /// It then reduces the query items into a dictionary where each key is a query parameter name,
    /// and each value is the corresponding query parameter value. If no query items exist, it returns an empty dictionary.
    var queryItems: [String: String] {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: String]()) { result, item in
                result[item.name] = item.value
            } ?? [:]
    }
}
