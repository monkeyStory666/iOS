/**
 A property wrapper for storing and retrieving a value from a preferences use case.

 The wrapper uses a preference key (conforming to `PreferenceKeyProtocol`) to access a value of type `V`
 via a `PreferenceUseCaseProtocol`. If no value is stored, the `defaultValue` will be returned.
 
 - Note: The wrapper is marked as `@unchecked Sendable`, so be sure that the underlying use case access
         is performed in a thread-safe manner.
 */
@propertyWrapper
public final class PreferenceWrapper<V, K: PreferenceKeyProtocol>: @unchecked Sendable {
    /// The key used to store and retrieve the preference value.
    private let key: K
    /// The default value returned if no value exists in the preferences.
    private let defaultValue: V
    
    /// The preference use case used to read and write the preference value.
    /// This is stored as an existential of type `any PreferenceUseCaseProtocol`.
    public var useCase: any PreferenceUseCaseProtocol
    
    /**
     A Boolean value indicating whether a preference value for the given key already exists.
     
     It returns `true` if a value of type `V` is found in the underlying use case; otherwise, `false`.
     */
    public var existed: Bool {
        let value: V? = useCase[key.rawValue]
        return value != nil
    }
    
    /**
     Initializes a new `PreferenceWrapper` with the specified key, default value, and use case.
     
     - Parameters:
       - key: The preference key conforming to `PreferenceKeyProtocol`.
       - defaultValue: The default value to use if no value is set.
       - useCase: The preference use case used to store and retrieve the value. The default is an empty preference use case.
     */
    public init(
        key: K,
        defaultValue: V,
        useCase: some PreferenceUseCaseProtocol = PreferenceUseCase.empty
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.useCase = useCase
    }
    
    /// Provides the projected value, which in this case is the wrapper itself.
    public var projectedValue: PreferenceWrapper<V, K> { self }
    
    /**
     Removes the preference value associated with the key.
     
     After calling this method, any subsequent access of the wrapped value will return the default value.
     */
    public func remove() {
        useCase[key.rawValue] = Optional<V>.none
    }
    
    /**
     The wrapped value stored in the preferences.
     
     - When getting the value, it retrieves the value from the `useCase` based on the key; if no value exists,
       it returns the provided default value.
     - When setting the value, it stores the new value in the `useCase` for the corresponding key.
     
     - Returns: The value of type `V` from the preferences, or the default value if not set.
     */
    public var wrappedValue: V {
        get {
            useCase[key.rawValue] ?? defaultValue
        }
        set {
            useCase[key.rawValue] = newValue
        }
    }
}
