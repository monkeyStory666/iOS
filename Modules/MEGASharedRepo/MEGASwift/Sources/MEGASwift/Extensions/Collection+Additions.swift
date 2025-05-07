public extension Collection {
    /// A Boolean value indicating whether the collection is not empty.
    ///
    /// When you need to check whether your collection is not empty, use the
    /// `isNotEmpty` property instead of checking that the `count` property is
    /// greater than zero. For collections that don't conform to
    /// `RandomAccessCollection`, accessing the `count` property iterates
    /// through the elements of the collection.
    /// - Complexity: O(1)
    var isNotEmpty: Bool {
        !isEmpty
    }
}
