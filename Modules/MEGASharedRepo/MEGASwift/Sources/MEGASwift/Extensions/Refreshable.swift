infix operator ↻↻: ComparisonPrecedence
infix operator !↻: ComparisonPrecedence

infix operator ↻↻⏿: ComparisonPrecedence
infix operator !↻⏿: ComparisonPrecedence

/// A protocol for types that define a custom refresh comparison.
///
/// Conforming types should implement the custom operator `↻↻` to determine whether two instances meet
/// a specific "refresh" condition. This condition can be used to decide if a refresh action is required.
public protocol Refreshable {
    /// Custom refresh comparison operator.
    ///
    /// Returns `true` if the left-hand side instance and the right-hand side instance meet the refresh criteria.
    static func ↻↻ (lhs: Self, rhs: Self) -> Bool
}

/// Provides a default implementation for the negated refresh comparison operator.
///
/// The `!↻` operator returns the logical negation of `↻↻`. It returns `true` if the two instances do NOT meet
/// the refresh criteria.
public extension Refreshable {
    static func !↻ (lhs: Self, rhs: Self) -> Bool {
        !(lhs ↻↻ rhs)
    }
}

/// A protocol for types that define a custom refresh comparison when the element is visible.
///
/// Conforming types should implement the custom operator `↻↻⏿` to determine whether two instances meet
/// a refresh criteria specific to when they are visible.
public protocol RefreshableWhenVisible {
    /// Custom refresh comparison operator for visible elements.
    ///
    /// Returns `true` if the left-hand side instance and the right-hand side instance meet the refresh criteria when visible.
    static func ↻↻⏿ (lhs: Self, rhs: Self) -> Bool
}

/// Provides a default implementation for the negated refresh comparison operator for visible elements.
///
/// The `!↻⏿` operator returns the logical negation of `↻↻⏿`. It returns `true` if the two instances do NOT meet
/// the refresh criteria when visible.
public extension RefreshableWhenVisible {
    static func !↻⏿ (lhs: Self, rhs: Self) -> Bool {
        !(lhs ↻↻⏿ rhs)
    }
}
