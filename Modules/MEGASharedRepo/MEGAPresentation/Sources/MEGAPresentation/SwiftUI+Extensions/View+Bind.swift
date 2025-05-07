#if canImport(SwiftUI)

import SwiftUI

extension View {
    /// Synchronizes view model state to view state via two-way bindings.
    ///
    /// SwiftUI comes with many property wrappers that can be used in views to drive view state,
    /// like field focus. Unfortunately, these property wrappers _must_ be used in views. It's not
    /// possible to extract this logic to a view model and integrate it with the rest of
    /// the view model's business logic, and be in a better position to test this state.
    ///
    /// We can work around these limitations by introducing a published field to your view model
    /// and synchronizing it to view state with this view modifier.
    ///
    /// - Parameters:
    ///   - viewModelValue: A binding from view model state. _E.g._, a binding derived from a field
    ///     on an observable class.
    ///   - viewValue: A binding from view state. _E.g._, a focus binding.
    ///
    /// ### Example
    /// ```swift
    /// final class PINCodeViewModel: NoRouteViewModel {
    ///     @ViewProperty var hasFocus: Bool = true
    ///     // Other properties and logic...
    /// }
    ///
    /// struct PINCodeView: View {
    ///     @StateObject var viewModel: PINCodeViewModel
    ///     @FocusState var hasFocus: Bool
    ///
    ///     var body: some View {
    ///         content
    ///             .bind($viewModel.hasFocus, to: $hasFocus)
    ///     }
    /// }
    /// ```
    @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
    public func bind<ViewModelValue: _Bindable, ViewValue: _Bindable>(
        _ viewModelValue: ViewModelValue, to viewValue: ViewValue
    ) -> some View
    where ViewModelValue.Value == ViewValue.Value, ViewModelValue.Value: Equatable {
        self.modifier(_Bind(viewModelValue: viewModelValue, viewValue: viewValue))
    }
}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
private struct _Bind<ViewModelValue: _Bindable, ViewValue: _Bindable>: ViewModifier
where ViewModelValue.Value == ViewValue.Value, ViewModelValue.Value: Equatable {
    let viewModelValue: ViewModelValue
    let viewValue: ViewValue

    @State var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !self.hasAppeared else { return }
                self.hasAppeared = true
                guard self.viewValue.wrappedValue != self.viewModelValue.wrappedValue else { return }
                self.viewValue.wrappedValue = self.viewModelValue.wrappedValue
            }
            .onChange(of: self.viewModelValue.wrappedValue) {
                guard self.viewValue.wrappedValue != $0
                else { return }
                self.viewValue.wrappedValue = $0
            }
            .onChange(of: self.viewValue.wrappedValue) {
                guard self.viewModelValue.wrappedValue != $0
                else { return }
                self.viewModelValue.wrappedValue = $0
            }
    }
}

public protocol _Bindable {
    associatedtype Value
    var wrappedValue: Value { get nonmutating set }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension AccessibilityFocusState: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension AccessibilityFocusState.Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension AppStorage: _Bindable {}

extension Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension FocusedBinding: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension FocusState: _Bindable {}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension FocusState.Binding: _Bindable {}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension SceneStorage: _Bindable {}

extension State: _Bindable {}

#endif  // canImport(SwiftUI)
