import Foundation

/**
 A mock implementation of `PreferenceUseCaseProtocol` for testing purposes.

 This mock use case stores preference values in an in-memory dictionary.
 It can be used as a lightweight substitute for a full-fledged preference repository during testing.
 
 - Note: This class is marked as `@unchecked Sendable` since it does not guarantee thread-safe
   access to its underlying dictionary. Use with caution in concurrent contexts.
 */
public final class MockPreferenceUseCase: PreferenceUseCaseProtocol, @unchecked Sendable {
    /// An in-memory dictionary that holds preference values.
    public var dict: [String: Any]

    /**
     Initializes a new `MockPreferenceUseCase` with an optional initial dictionary.
     
     - Parameter dict: A dictionary containing initial preference key-value pairs. Defaults to an empty dictionary.
     */
    public init(dict: [String: Any] = [:]) {
        self.dict = dict
    }

    /**
     A generic subscript for accessing and modifying preference values.
     
     The subscript retrieves a value for the specified key and attempts to cast it to type `T`.
     When setting a value, it updates the underlying dictionary accordingly.
     
     - Parameter key: A `String` that specifies the key for the preference value.
     - Returns: The value associated with the given key as type `T`, or `nil` if the key does not exist
       or if the value cannot be cast to type `T`.
     */
    public subscript<T>(key: String) -> T? {
        get {
            dict[key] as? T
        }
        set(newValue) {
            dict[key] = newValue
        }
    }
}
