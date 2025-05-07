import Foundation

public extension Array {
    /// Initializes an array using the provided number of items function, item at index function, and map function.
    ///
    /// - Parameters:
    ///   - numberOfItems: A function that returns the number of items.
    ///   - itemAtIndex: A function that returns the item at a specific index.
    ///   - mapFunction: A function that maps the item to the desired element type.
    init<Item>(
        numberOfItems: @autoclosure () -> Int,
        itemAtIndex: (Int) -> Item?,
        mapFunction: (Item) -> Element
    ) {
        let count = numberOfItems()
        self.init()
        self.reserveCapacity(count)
        
        for index in 0..<count {
            if let item = itemAtIndex(index) {
                let mappedItem = mapFunction(item)
                self.append(mappedItem)
            }
        }
    }
}

public extension Array {
    /// Safely accesses the element at the specified index.
    ///
    /// This subscript returns the element at the given index if it is within bounds,
    /// otherwise it returns `nil`.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: The element at the specified index if it exists; otherwise, `nil`.
    subscript(safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

public extension Array where Element: Equatable {
    /// Moves the first occurrence of the specified item to a new index.
    ///
    /// If the item exists in the array, it is removed from its current position and inserted at the new index.
    /// If the item is not found, no change is made.
    ///
    /// - Parameters:
    ///   - item: The element to move.
    ///   - newIndex: The index where the element should be placed.
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item) {
            move(at: index, to: newIndex)
        }
    }
    
    /// Brings the specified item to the front of the array.
    ///
    /// This method moves the first occurrence of the item to the beginning (index 0) of the array.
    ///
    /// - Parameter item: The element to bring to the front.
    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }
    
    /// Sends the specified item to the back of the array.
    ///
    /// This method moves the first occurrence of the item to the end of the array.
    ///
    /// - Parameter item: The element to send to the back.
    mutating func sendToBack(item: Element) {
        move(item, to: endIndex - 1)
    }
    
    /// Returns a new array with the elements shifted by the specified distance.
    ///
    /// The shifting operation rotates the array so that elements are moved from one end to the other.
    /// A positive `distance` shifts elements from the beginning to the end, while a negative `distance`
    /// shifts elements from the end to the beginning.
    ///
    /// - Parameter distance: The number of positions to shift the elements. Defaults to 1.
    /// - Returns: A new array with the elements shifted by the specified distance.
    func shifted(_ distance: Int = 1) -> [Element] {
        let offsetIndex = distance >= 0 ?
        index(startIndex, offsetBy: distance, limitedBy: endIndex) :
        index(endIndex, offsetBy: distance, limitedBy: startIndex)
        
        guard let index = offsetIndex else { return self }
        return Array(self[index..<endIndex] + self[startIndex..<index])
    }
    
    /// Shifts the array's elements in place by the specified distance.
    ///
    /// This method rotates the array's elements, modifying the array itself.
    ///
    /// - Parameter distance: The number of positions to shift the elements. Defaults to 1.
    mutating func shift(_ distance: Int = 1) {
        self = shifted(distance)
    }
}

// MARK: - Array Extension for Moving Elements

public extension Array {
    /// Moves the element at the specified index to a new index within the array.
    ///
    /// This method removes the element at the given index and inserts it at the specified new index.
    ///
    /// - Parameters:
    ///   - index: The current index of the element to move.
    ///   - newIndex: The destination index where the element should be inserted.
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}

// MARK: - Array Extension for Hashable Elements

public extension Array where Element: Hashable {
    /// Returns a new array with duplicate elements removed, preserving the original order.
    ///
    /// This method leverages `NSOrderedSet` to filter out duplicates while maintaining the
    /// order of the first occurrence of each element.
    ///
    /// - Returns: An array containing only unique elements in the original order.
    func removeDuplicatesWhileKeepingTheOriginalOrder() -> [Element] {
        NSOrderedSet(array: self).array as? [Element] ?? []
    }
}

public extension Array where Element: Equatable {
    /// Remove the object from array
    ///
    /// - parameter object: The element need to remove
    ///
    /// Time Complexity: O(n)
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
}

public extension Array where Element == String {
    /// Returns a new array where each element is prefixed with the specified string.
    ///
    /// This method does not modify the original array but instead returns a new array
    /// where each element is prefixed by the provided string.
    ///
    /// - Parameter prefix: The string to prepend to each element in the array.
    /// - Returns: A new array of strings where each element is prefixed with `prefix`.
    func elementsPrepended(with prefix: String) -> [String] {
        map { prefix + $0 }
    }
}
