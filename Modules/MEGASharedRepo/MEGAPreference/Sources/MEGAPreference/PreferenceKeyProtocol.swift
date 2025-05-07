/// Defines a protocol for enums representing preference keys as strings. It is intended for enums like `PreferenceKeyEntity`
/// to adopt this protocol, allowing them to be used as keys for managing preferences. Enums conforming to this protocol
/// should declare cases that correspond to the preference keys.
///
/// Example:
/// ```swift
/// enum PreferenceKeyEntity: String, PreferenceKeyProtocol {
///     case isFirstLaunch
/// }
/// ```
public protocol PreferenceKeyProtocol {
    var rawValue: String { get }
}
