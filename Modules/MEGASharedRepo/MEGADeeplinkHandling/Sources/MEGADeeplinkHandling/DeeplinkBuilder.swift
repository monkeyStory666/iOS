import Foundation

/// A builder for constructing composite deep link handlers.
///
/// `DeeplinkBuilder` allows you to specify criteria (such as scheme, host, path, and fragment)
/// for validating URLs. It supports both custom predicate closures and simple string matching.
/// You can also optionally supply child handlers to create composite deep link handling logic.
public class DeeplinkBuilder {
    /// A closure type used to validate a non-optional string value.
    public typealias ValidateString = (String) -> Bool
    /// A closure type used to validate an optional string value.
    public typealias ValidateOptionalString = (String?) -> Bool
    
    private var schemePredicates: [ValidateString] = []
    private var hostPredicates: [ValidateString] = []
    private var pathPredicates: [ValidateString] = []
    private var fragmentPredicates: [ValidateOptionalString] = []
    
    /// Initializes a new instance of `DeeplinkBuilder`.
    public init() {}
    
    // MARK: - Scheme Configuration
    
    /// Adds one or more custom scheme validation predicates.
    ///
    /// - Parameter predicates: A variadic list of closures that validate a scheme.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func scheme(_ predicates: ValidateString...) -> DeeplinkBuilder {
        schemePredicates.append(contentsOf: predicates)
        return self
    }
    
    /// Adds one or more scheme strings for equality matching (case-insensitive).
    ///
    /// - Parameter schemes: A variadic list of scheme strings.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func scheme(_ schemes: String...) -> DeeplinkBuilder {
        schemePredicates.append(contentsOf: schemes.map { scheme in
            { $0.lowercased() == scheme.lowercased() }
        })
        return self
    }
    
    // MARK: - Host Configuration
    
    /// Adds one or more custom host validation predicates.
    ///
    /// - Parameter predicates: A variadic list of closures that validate a host.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func host(_ predicates: ValidateString...) -> DeeplinkBuilder {
        hostPredicates.append(contentsOf: predicates)
        return self
    }
    
    /// Adds one or more host strings for equality matching (case-insensitive).
    ///
    /// - Parameter hosts: A variadic list of host strings.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func host(_ hosts: String...) -> DeeplinkBuilder {
        hostPredicates.append(contentsOf: hosts.map { host in
            { $0.lowercased() == host.lowercased() }
        })
        return self
    }
    
    // MARK: - Path Configuration
    
    /// Adds one or more custom path validation predicates.
    ///
    /// - Parameter predicates: A variadic list of closures that validate a path.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func path(_ predicates: ValidateString...) -> DeeplinkBuilder {
        pathPredicates.append(contentsOf: predicates)
        return self
    }
    
    /// Adds one or more path strings for equality matching.
    ///
    /// Note: This method supports both leading slash and non-leading slash variants.
    ///
    /// - Parameter paths: A variadic list of path strings.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func path(_ paths: String...) -> DeeplinkBuilder {
        pathPredicates.append(contentsOf: paths.map { path in
            { $0 == path }
        })
        return self
    }
    
    // MARK: - Fragment Configuration
    
    /// Adds an array of custom fragment validation predicates.
    ///
    /// - Parameter predicates: An array of closures that validate a fragment.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func fragment(_ predicates: [ValidateOptionalString]) -> DeeplinkBuilder {
        fragmentPredicates.append(contentsOf: predicates)
        return self
    }
    
    /// Adds one or more custom fragment validation predicates.
    ///
    /// - Parameter predicates: A variadic list of closures that validate a fragment.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func fragment(_ predicates: ValidateOptionalString...) -> DeeplinkBuilder {
        fragment(predicates)
    }
    
    /// Adds an array of fragment strings for equality matching.
    ///
    /// - Parameter fragments: An array of fragment strings.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func fragment(_ fragments: [String]) -> DeeplinkBuilder {
        fragmentPredicates.append(contentsOf: fragments.map { fragment in
            { $0 == fragment }
        })
        return self
    }
    
    /// Adds one or more fragment strings for equality matching.
    ///
    /// - Parameter fragments: A variadic list of fragment strings.
    /// - Returns: The current builder instance for method chaining.
    @discardableResult
    public func fragment(_ fragments: String...) -> DeeplinkBuilder {
        fragment(fragments)
    }
    
    // MARK: - Build
    
    /// Builds and returns a deep link handler using the configured predicates.
    ///
    /// - Parameters:
    ///   - childHandlers: An optional array of child deep link handlers.
    ///   - handler: An optional closure to handle the URL if it passes validation.
    /// - Returns: A concrete instance conforming to `DeeplinkHandling` that incorporates the specified criteria.
    public func build(
        withChildHandlers childHandlers: [DeeplinkHandling]? = nil,
        handler: ((URL) -> Void)? = nil
    ) -> DeeplinkHandling {
        BuiltDeeplinkHandler(
            schemes: schemePredicates,
            hosts: hostPredicates,
            paths: pathPredicates,
            fragments: fragmentPredicates,
            handler: handler,
            childHandlers: childHandlers
        )
    }
    
    // MARK: - Internal Built Handler
    
    /// A concrete deep link handler built by `DeeplinkBuilder` using the provided criteria.
    private struct BuiltDeeplinkHandler: DeeplinkHandling {
        let schemes: [ValidateString]
        let hosts: [ValidateString]
        let paths: [ValidateString]
        let fragments: [ValidateOptionalString]
        let handler: ((URL) -> Void)?
        let childHandlers: [DeeplinkHandling]?
        
        init(
            schemes: [ValidateString],
            hosts: [ValidateString],
            paths: [ValidateString],
            fragments: [ValidateOptionalString],
            handler: ((URL) -> Void)? = nil,
            childHandlers: [DeeplinkHandling]? = nil
        ) {
            self.schemes = schemes
            self.hosts = hosts
            self.paths = paths
            self.fragments = fragments
            self.handler = handler
            self.childHandlers = childHandlers
        }
        
        /// Determines whether the handler can process the given URL by evaluating all criteria.
        ///
        /// - Parameter url: The URL to validate.
        /// - Returns: `true` if the URL meets all criteria; otherwise, `false`.
        func canHandle(_ url: URL) -> Bool {
            isSchemeValid(in: url)
            && isHostValid(in: url)
            && isPathValid(in: url)
            && isFragmentValid(in: url)
            && canBeHandledByChildHandlers(url)
        }
        
        /// Processes the URL if it passes validation.
        ///
        /// If any child handler can handle the URL, that handler is invoked. Otherwise, the main handler is executed.
        ///
        /// - Parameter url: The URL to process.
        func handle(_ url: URL) {
            guard canHandle(url) else { return }
            
            if let childHandlers = childHandlers {
                for handler in childHandlers where handler.canHandle(url) {
                    handler.handle(url)
                    return
                }
            } else {
                self.handler?(url)
            }
        }
        
        // MARK: - Private Validation Methods
        
        /// Validates the URL's scheme against the configured predicates.
        private func isSchemeValid(in url: URL) -> Bool {
            guard !schemes.isEmpty else { return true }
            guard let urlScheme = url.scheme else { return false }
            return schemes.contains { $0(urlScheme) }
        }
        
        /// Validates the URL's host against the configured predicates.
        private func isHostValid(in url: URL) -> Bool {
            guard !hosts.isEmpty else { return true }
            guard let urlHost = url.host else { return false }
            return hosts.contains { $0(urlHost) }
        }
        
        /// Validates the URL's path against the configured predicates.
        ///
        /// This method also supports validation for paths without a leading slash.
        private func isPathValid(in url: URL) -> Bool {
            guard !paths.isEmpty else { return true }
            return paths.contains {
                // Allow matching with or without a leading slash.
                $0(url.path) || $0(String(url.path.dropFirst()))
            }
        }
        
        /// Validates the URL's fragment against the configured predicates.
        private func isFragmentValid(in url: URL) -> Bool {
            guard !fragments.isEmpty else { return true }
            return fragments.contains { $0(url.fragment) }
        }
        
        /// Checks if the URL can be handled by any child handler.
        private func canBeHandledByChildHandlers(_ url: URL) -> Bool {
            guard let childHandlers = childHandlers else { return true }
            return childHandlers.contains { $0.canHandle(url) }
        }
    }
}
