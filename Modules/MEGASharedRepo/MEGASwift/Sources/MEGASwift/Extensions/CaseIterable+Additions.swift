/**
 A convenience extension for types that conform to both `CaseIterable` and `RawRepresentable`.

 This extension provides a static property `allValues` that returns an array of all the raw values
 for the cases of the conforming type.
 
 - Note: This extension is only applicable to types that conform to both `CaseIterable` and `RawRepresentable`.
 */
public extension CaseIterable where Self: RawRepresentable {
    /// An array containing the raw values of all cases.
    static var allValues: [RawValue] {
        return allCases.map { $0.rawValue }
    }
}
