/**
 A protocol that defines a repository for storing and retrieving preferences.
 
 Conforming types should support getting and setting values associated with a string key.
 The protocol inherits from `Sendable`, ensuring that implementations can be safely used in concurrent contexts.
 */
public protocol PreferenceRepositoryProtocol: Sendable {
    /// A subscript for accessing and modifying preference values.
    ///
    /// - Parameter key: The key associated with the preference value.
    /// - Returns: The value of type `T` corresponding to the key, or `nil` if no value exists.
    subscript<T>(key: String) -> T? { get set }
}

/**
 An empty implementation of `PreferenceRepositoryProtocol` that does not store any data.
 
 This implementation always returns `nil` for any key and ignores any values set via the subscript.
 It can be used as a default or placeholder implementation.
 */
public struct EmptyPreferenceRepository: PreferenceRepositoryProtocol {
    
    /// Creates and returns a new, empty preference repository.
    public static var newRepo: EmptyPreferenceRepository {
        EmptyPreferenceRepository()
    }
    
    /// A subscript for getting and setting values in the repository.
    ///
    /// This implementation always returns `nil` on get and does nothing on set.
    ///
    /// - Parameter key: The key for which to retrieve or set a value.
    /// - Returns: Always returns `nil` when getting a value.
    public subscript<T>(key: String) -> T? {
        get {
            nil
        }
        set { }
    }
}
