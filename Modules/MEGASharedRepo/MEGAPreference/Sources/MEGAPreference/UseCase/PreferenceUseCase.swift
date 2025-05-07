/**
 A protocol defining the interface for a preference use case.
 
 Conforming types allow accessing and updating preferences using a subscript
 interface keyed by String. This protocol is marked as Sendable to ensure that
 implementations can safely be used in concurrent contexts.
 */
public protocol PreferenceUseCaseProtocol: Sendable {
    /// A generic subscript for getting and setting preference values.
    ///
    /// - Parameter key: A string key associated with a preference value.
    /// - Returns: The value for the given key if it exists, or `nil` otherwise.
    subscript<T>(key: String) -> T? { get set }
}

/**
 A generic preference use case that wraps an underlying repository conforming to `PreferenceRepositoryProtocol`.
 
 This structure provides a unified subscript interface to access and modify preferences via the provided repository.
 
 - Note: The repository is stored as a private property and used to perform the actual get/set operations.
 */
public struct PreferenceUseCase<T: PreferenceRepositoryProtocol>: PreferenceUseCaseProtocol {
    /// The underlying repository used for storing and retrieving preferences.
    private var repo: T
    
    /**
     Initializes a new `PreferenceUseCase` with the provided preference repository.
     
     - Parameter repository: An instance conforming to `PreferenceRepositoryProtocol` used as the backend for preferences.
     */
    public init(repository: T) {
        repo = repository
    }
    
    /**
     A generic subscript for accessing and modifying preference values.
     
     The getter retrieves the value from the underlying repository, while the setter updates the repository.
     
     - Parameter key: The key for which to retrieve or set the preference value.
     - Returns: The value of type `V` associated with the key, or `nil` if not found.
     */
    public subscript<V>(key: String) -> V? {
        get {
            repo[key]
        }
        set {
            repo[key] = newValue
        }
    }
}

/**
 A convenience extension for `PreferenceUseCase` when the underlying repository is `EmptyPreferenceRepository`.
 
 This extension provides a default, empty preference use case implementation.
 */
public extension PreferenceUseCase where T == EmptyPreferenceRepository {
    /// A static property returning an empty `PreferenceUseCase`.
    ///
    /// This empty use case can serve as a placeholder or default preference repository that does nothing.
    static var empty: PreferenceUseCase {
        PreferenceUseCase(repository: EmptyPreferenceRepository())
    }
}

/**
 Convenience extensions for creating a `PreferenceUseCase`
 
 specifically when its generic `T` is `PreferenceRepository`.
 */
public extension PreferenceUseCase where T == PreferenceRepository {
    
    /// The default `PreferenceUseCase` configured with the standard
    /// `PreferenceRepository` instance.
    ///
    /// Use this when you need a `PreferenceUseCase` without providing
    /// a custom repository.
    ///
    /// - Returns: A `PreferenceUseCase` initialized with
    ///   `PreferenceRepository.newRepo`.
    static var `default`: PreferenceUseCase {
        .init(repository: PreferenceRepository.newRepo)
    }
}
