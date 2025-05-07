// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import SwiftUI

public protocol ViewPropertyProtocol: AnyObject {
    var owner: ViewModelBase? { get set }
}

/// `ViewProperty` is a property wrapper similar to SwiftUI's @Published.
/// It's designed to automatically propagate changes to the UI, ensuring these changes
/// are always received on the main thread. It provides a mechanism to control whether
/// these updates should be animated.
///
/// ```
/// final class SampleViewModel: ViewModelBase {
///     @ViewProperty var data: SampleData?
///     @ViewProperty var isLoading = false
///
///     private let dataService: DataService
///
///     init(dataService: DataService) {
///         self.dataService = dataService
///     }
///
///     func fetchData() async {
///         _isLoading.updateWithoutAnimation(with: true)
///         data = await dataService.fetchData()
///         isLoading = false
///     }
/// }
/// ```
/// In the above example, `isLoading` is updated to true without triggering an animation,
/// while `data` and `isLoading = false` is updated with an animation.
@propertyWrapper
public final class ViewProperty<T>: ObservableObject, ViewPropertyProtocol {
    public weak var owner: ViewModelBase?

    private var value: T
    private let subject = PassthroughSubject<T, Never>()
    private var animation: Animation? = Animation.default

    /// The value being wrapped by the `ViewProperty`. Changes to this value are published
    /// on the main thread, and by default trigger an animation.
    public var wrappedValue: T {
        get {
            value
        }
        set {
            let updateValue = { [weak self] in
                self?.value = newValue
                self?.subject.send(newValue)
                self?.objectWillChange.send()

                // Ignore the purple warning in unit tests, it is expected
                self?.owner?.objectWillChange.send()
            }

            #if DEBUG
            guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
                return updateValue()
            }
            #endif

            DispatchQueue.main.async {
                withAnimation(self.animation) {
                    updateValue()
                }
            }
        }
    }

    public var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    public init(
        wrappedValue: T,
        animation: Animation? = Animation.default
    ) {
        self.value = wrappedValue
        self.animation = animation
    }

    /// Updates the wrapped value without triggering an animation.
    ///
    /// Example Usage:
    ///
    /// ```
    /// final class SampleViewModel: ViewModelBase {
    ///     @ViewProperty var isLoading = false
    ///
    ///     func performTask() {
    ///         _isLoading.updateWithoutAnimation(with: true)
    ///         // Perform some task
    ///         isLoading = false
    ///     }
    /// }
    /// ```
    /// In the above example, `isLoading` is updated without triggering an animation
    /// to reflect the beginning of a task. The completion of the task is signaled
    /// by setting `isLoading` to `false` which will be animated.
    ///
    /// - Parameter value: The new value.
    public func updateWithoutAnimation(with value: T) {
        animation = nil
        wrappedValue = value
    }

    /// Updates the wrapped value with the specified animation.
    ///
    /// This method allows for fine-grained control over how value updates are animated.
    /// By providing an `Animation` value, you can specify the exact animation used when updating
    /// the `ViewProperty`.
    /// If `nil` is provided, the default animation set for the `ViewProperty` is used.
    ///
    /// Example Usage:
    ///
    /// ```
    /// final class SampleViewModel: ViewModelBase {
    ///     @ViewProperty var progress = 0.0
    ///
    ///     func incrementProgress() {
    ///         let newProgress = progress + 0.1
    ///         _progress.updateWithAnimation(.easeInOut(duration: 0.5), with: newProgress)
    ///     }
    /// }
    /// ```
    /// In the above example, the `progress` value is updated with an ease-in-out animation over a
    /// duration of 0.5 seconds.
    ///
    /// - Parameters:
    ///   - animation: The animation to use when updating the value. If `nil`, the default animation
    /// is used.
    ///   - value: The new value.
    public func updateWithAnimation(_ animation: Animation?, with value: T) {
        self.animation = animation
        wrappedValue = value
    }
}
