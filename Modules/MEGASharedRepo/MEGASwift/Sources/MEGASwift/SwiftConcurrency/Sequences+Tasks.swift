public extension Array where Element == Task<Void, any Error> {
    
    ///  Create and store Task into this Sequence
    /// - Parameter action: Async block to run operation
    mutating func appendTask(_ action: @escaping @Sendable () async -> Void) {
        append(task(for: action))
    }
    
    /// Cancel and remove all Tasks in this Sequence
    mutating func cancelTasks() {
        cancelAllTasks()
        removeAll()
    }
}

public extension Set where Element == Task<Void, any Error> {
    
    ///  Create and store Task into this Sequence
    /// - Parameter action: Async block to run operation
    mutating func appendTask(_ action: @escaping @Sendable () async -> Void) {
        insert(task(for: action))
    }
    
    /// Cancel and remove all Tasks in this Sequence
    mutating func cancelTasks() {
        cancelAllTasks()
        removeAll()
    }
}

public extension Collection where Element: Sendable, Index == Int {
    /// Executes an asynchronous operation on each element of the collection concurrently using a task group.
    ///
    /// This method limits the number of concurrently running tasks to `maxConcurrentTasks`.
    /// It first starts tasks for the initial elements up to the maximum concurrency limit.
    /// Then, as tasks complete, it continues to add tasks for the remaining elements until all are processed.
    ///
    /// - Parameters:
    ///   - maxConcurrentTasks: The maximum number of tasks that are allowed to run concurrently. Defaults to 3.
    ///   - operation: A closure that takes an element from the collection and performs an asynchronous operation on it.
    ///
    /// - Note: The collection's index is assumed to be of type `Int`.
    func taskGroup(maxConcurrentTasks: Int = 3, operation: @Sendable @escaping (Element) async -> Void) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            // Limit the number of concurrent tasks to either the provided limit or the collection count, whichever is smaller.
            let maxConcurrentTasks = Swift.min(maxConcurrentTasks, count)
            
            // Start initial tasks for the first batch of elements.
            for item in self[0..<maxConcurrentTasks] {
                guard !Task.isCancelled else { break }
                taskGroup.addTask { await operation(item) }
            }
            
            var nextTaskIndex = maxConcurrentTasks
            
            // As tasks complete, add new tasks until all elements have been processed.
            for await _ in taskGroup where nextTaskIndex < count {
                guard !Task.isCancelled else { break }
                let item = self[nextTaskIndex]
                nextTaskIndex += 1
                taskGroup.addTask { await operation(item) }
            }
        }
    }
}

fileprivate extension Sequence where Element == Task<Void, any Error> {
    /// Creates a new task that executes the given asynchronous action.
    ///
    /// - Parameter action: A closure representing an asynchronous action.
    /// - Returns: A new `Task` that executes the provided action.
    func task(for action: @escaping @Sendable () async -> Void) -> Task<Void, any Error> {
        Task { await action() }
    }
    
    /// Cancels all tasks in the sequence.
    ///
    /// This method iterates over the sequence of tasks and cancels each one.
    func cancelAllTasks() {
        forEach { $0.cancel() }
    }
}
