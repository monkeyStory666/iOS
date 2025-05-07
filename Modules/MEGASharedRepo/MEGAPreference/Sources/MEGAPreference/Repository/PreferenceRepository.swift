import Foundation
import MEGASwift

/// A lightweight repository for storing and retrieving user preferences.
///
/// `PreferenceRepository` is a thin wrapper around `UserDefaults` that
/// provides typed, subscript‑based access to values.
/// It conforms to `PreferenceRepositoryProtocol`, allowing it to be used
/// interchangeably with other preference‑storage implementations.
///
/// - Thread‑Safety: The repository relies on the thread‑safety guarantees
///   of `UserDefaults`. Marked `nonisolated(unsafe)` to permit synchronous
///   cross‑actor access without introducing an actor hop. Use with care if
///   you need stronger concurrency guarantees.
public final class PreferenceRepository: PreferenceRepositoryProtocol {
    
    // MARK: - Convenience
    
    /// A repository backed by `UserDefaults.standard`.
    ///
    /// ```swift
    /// let repo = PreferenceRepository.newRepo
    /// repo["hasSeenOnboarding"] = true
    /// ```
    public static var newRepo: PreferenceRepository {
        PreferenceRepository(userDefaults: .standard)
    }
    
    // MARK: - Storage backend
    
    /// The underlying `UserDefaults` instance.
    ///
    /// Declared `nonisolated(unsafe)` so that it can be accessed from any
    /// actor without suspension. The `unsafe` keyword means the caller is
    /// responsible for ensuring correct synchronization if required.
    private nonisolated(unsafe) var userDefaults: UserDefaults
    
    // MARK: - Initialisation
    
    /// Creates a repository that wraps the specified `UserDefaults`.
    ///
    /// - Parameter userDefaults: The user‑defaults database used to persist
    ///   preference values.
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Subscript Access
    
    /// Accesses the preference value associated with the given key.
    ///
    /// Values are bridged to and from Objective‑C automatically.
    /// Generic casting makes read/write syntax concise while preserving type
    /// safety at the call‑site.
    ///
    /// ```swift
    /// repo["launchCount"] = (repo["launchCount"] ?? 0) + 1
    /// let token: String? = repo["authToken"]
    /// ```
    ///
    /// - Parameter key: The key that identifies the preference value.
    /// - Returns: The stored value cast to type `T`, or `nil` if no value is
    ///   stored under `key` or if casting fails.
    public subscript<T>(key: String) -> T? {
        get {
            userDefaults.object(forKey: key) as? T
        }
        set {
            userDefaults.set(newValue, forKey: key)
        }
    }
}

// MARK: - Sendable

/// Conformance to `Sendable` allows the repository to cross actor bounds.
///
/// The implementation is marked `@unchecked` because `UserDefaults` does not
/// itself conform to `Sendable`. Only call‑sites that understand the thread‑
/// safety implications should use the repository concurrently.
extension PreferenceRepository: @unchecked Sendable {}
