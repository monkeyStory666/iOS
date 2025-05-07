import Foundation

infix operator ~~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence

/**
 A protocol that defines a custom matching operator for comparing instances.
 
 Types conforming to `Matchable` must implement the custom matching operator `~~`
 to determine whether two instances "match" according to custom logic.
 */
public protocol Matchable {
    /// Determines if two instances match.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side instance.
    ///   - rhs: The right-hand side instance.
    /// - Returns: `true` if the two instances match; otherwise, `false`.
    static func ~~ (lhs: Self, rhs: Self) -> Bool
}

/**
 Provides a default implementation for the negated matching operator.
 
 The `!~` operator returns the logical negation of the custom matching operator `~~`.
 */
public extension Matchable {
    /// Returns the inverse of the custom matching result.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side instance.
    ///   - rhs: The right-hand side instance.
    /// - Returns: `true` if the two instances do not match; otherwise, `false`.
    static func !~ (lhs: Self, rhs: Self) -> Bool {
        !(lhs ~~ rhs)
    }
}

/**
 Extends `Array` to conform to `Matchable` when its elements conform to `Matchable`.
 
 This extension implements the custom matching operator for arrays by comparing their elements pairwise.
 */
extension Array: Matchable where Element: Matchable {
    /// Compares two arrays element-by-element using the custom matching operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side array.
    ///   - rhs: The right-hand side array.
    /// - Returns: `true` if both arrays have the same count and each corresponding pair of elements match;
    ///            otherwise, `false`.
    public static func ~~ (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy(~~)
    }
}

/**
 Extends `Optional` to conform to `Matchable` when its wrapped type conforms to `Matchable`.
 
 This extension defines matching for optional values:
 - If both optionals are `nil`, they are considered to match.
 - If only one is `nil`, they do not match.
 - Otherwise, the wrapped values are compared using the custom matching operator.
 */
extension Optional: Matchable where Wrapped: Matchable {
    /// Compares two optional values using the custom matching operator.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side optional value.
    ///   - rhs: The right-hand side optional value.
    /// - Returns: `true` if both are `nil`, or if both contain values that match according to `~~`;
    ///            otherwise, `false`.
    public static func ~~ (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        if lhs == nil && rhs == nil { return true }
        guard let lhs = lhs, let rhs = rhs else { return false }
        return lhs ~~ rhs
    }
}
