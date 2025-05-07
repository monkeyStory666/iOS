// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Testing
import XCTest

/// A base class for creating mock objects that helps track and assert actions.
///
/// Example Usage:
///
///     // Create a subclass of `MockObject`
///     final class MyObjectMock: MockObject<MyObjectMock.Action>, MyObjectProtocol {
///         enum Action: Equatable {
///             case action1
///             case action2(Int)
///         }
///         // Additional implementation or overrides if needed
///
///         func performAction1() {
///             actions.append(.action1)
///         }
///
///         func performAction2(with value: Int) {
///             actions.append(.action2(value))
///         }
///     }
///
///     // Implement the interface or methods to be mocked
///     protocol MyObjectProtocol {
///         func performAction1()
///         func performAction2(with value: Int)
///     }
///
///     class MyObjectParent: MyObjectParentProtocol {
///         let myObject: MyObjectProtocol
///
///         init(myObject: MyObjectProtocol) {
///             self.myObject = myObject
///         }
///
///         func performAction1() {
///             myObject.performAction1()
///         }
///
///         func performAction2(with value: Int) {
///             myObject.performAction2(with: value)
///         }
///     }
///
///     // Use the mock object in tests and perform assertions
///     func testMyObject() {
///         let mockObject = MyObjectMock()
///         let myObject = MyObjectParent(myObject: mockObject)
///
///         myObject.performAction1()
///         myObject.performAction2(with: 2)
///         myObject.performAction2(with: 2)
///         myObject.performAction2(with: 3)
///         myObject.performAction2(with: 3)
///         myObject.performAction2(with: 3)
///
///         // Assert the recorded actions
///         mockObject.assertActions(shouldBe: [.action1, .action2(42)])
///         mockObject.assert(.action1, isCalled: .once)
///         mockObject.assert(.action2(2), isCalled: .twice)
///         mockObject.assert(.action2(3), isCalled: 3.times)
///     }
open class MockObject<Action: Equatable> {
    private let actionsQueue = DispatchQueue(label: "mockObjectQueue.\(UUID().uuidString)", attributes: .concurrent)
    private var _actions = [Action]()

    public var actions: [Action] {
        get {
            actionsQueue.sync {
                _actions
            }
        }
        set {
            actionsQueue.sync(flags: .barrier) {
                self._actions = newValue
                self.actionsSubject.send(newValue)
            }
        }
    }

    private var actionsSubject = PassthroughSubject<[Action], Never>()
    public var actionsPublisher: AnyPublisher<[Action], Never> {
        actionsQueue.sync {
            actionsSubject.eraseToAnyPublisher()
        }
    }

    public init() {}

    /// Asserts that a specific action has been called a certain number of times.
    ///
    /// - Parameters:
    ///   - action: The action to assert.
    ///   - expectedCallFrequency: The expected frequency of the action call.
    ///   - file: The file name to report in case of a failure. Defaults to the current file.
    ///   - line: The line number to report in case of a failure. Defaults to the current line.
    ///
    /// Example Usage:
    ///
    ///     mockObject.assert(.action1, isCalled: .once)
    ///     mockObject.assert(.action2(42), isCalled: .twice)
    ///     mockObject.assert(.action2(42), isCalled: 3.times)
    public func assert(
        _ action: Action,
        isCalled expectedCallFrequency: CallFrequency,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertActions(
            where: { $0 == action },
            isCalled: expectedCallFrequency,
            file: file,
            line: line
        )
    }

    /// Asserts that a set of actions meet a certain call frequency criteria based on a condition.
    ///
    /// - Parameters:
    ///   - isIncluded: A closure that takes an action and returns a Bool indicating whether the action should be included in the assertion.
    ///   - expectedCallFrequency: The expected frequency of the filtered action calls.
    ///   - file: The file name to report in case of a failure. Defaults to the current file.
    ///   - line: The line number to report in case of a failure. Defaults to the current line.
    ///
    /// Example Usage:
    ///
    ///     mockObject.assertActions(where: { $0 == .action1 }, isCalled: .once)
    ///     mockObject.assertActions(where: { $0 == .action2(42) }, isCalled: .twice)
    ///     mockObject.assertActions(where: { $0 == .action2(42) }, isCalled: 3.times)
    public func assertActions(
        where isIncluded: @Sendable (Action) -> Bool,
        isCalled expectedCallFrequency: CallFrequency,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            actions.filter { isIncluded($0) }.count,
            expectedCallFrequency,
            file: file, line: line
        )
    }

    /// Asserts that the total number of recorded actions matches the expected count.
    ///
    /// - Parameters:
    ///   - expectedActionsCallFrequency: The expected number of total actions.
    ///   - file: The file name to report in case of a failure. Defaults to the current file.
    ///   - line: The line number to report in case of a failure. Defaults to the current line.
    ///
    /// Example Usage:
    ///
    ///     mockObject.assertActionsCalled(.once)
    ///     mockObject.assertActionsCalled(.twice)
    ///     mockObject.assertActionsCalled(3.times)
    public func assertActionsCalled(
        _ expectedActionsCallFrequency: CallFrequency,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            actions.count,
            expectedActionsCallFrequency,
            file: file, line: line
        )
    }

    /// Asserts that the recorded actions match the expected actions in the given order.
    ///
    /// - Parameters:
    ///   - expectedActions: The expected array of actions.
    ///   - file: The file name to report in case of a failure. Defaults to the current file.
    ///   - line: The line number to report in case of a failure. Defaults to the current line.
    ///
    /// Example Usage:
    ///
    ///     mockObject.assertActions(shouldBe: [.action1, .action2(42)])
    public func assertActions(
        shouldBe expectedActions: [Action],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actions, expectedActions, file: file, line: line)
    }

    // MARK: - Swift Testing

    /// A namespace for functions used specifically in Swift Testing contexts.
    ///
    /// The `SWT` struct provides test-specific assertions that are scoped to the `mockObject`.
    /// These functions are tailored for use in Swift Testing (e.g., XCTest) to verify that
    /// the mock object's actions have been called with the expected frequency or conditions.
    ///
    /// Example Usage:
    ///
    ///     mockObject.swt.assert(.action1, isCalled: .once)
    ///     mockObject.swt.assertActions(where: { $0 == .action2(42) }, isCalled: .twice)
    ///     mockObject.swt.assertActionsCalled(3.times)
    public struct SWT {
        private let mockObject: MockObject

        init(mockObject: MockObject) {
            self.mockObject = mockObject
        }

        /// Asserts that a specific action has been called a certain number of times.
        ///
        /// This version of the function is intended specifically for use in Swift Testing contexts.
        /// It does not require file or line parameters, and utilizes the testing framework's built-in tools.
        ///
        /// - Parameters:
        ///   - action: The action to assert.
        ///   - expectedCallFrequency: The expected frequency of the action call.
        ///
        /// Example Usage:
        ///
        ///     mockObject.swt.assert(.action1, isCalled: .once)
        ///     mockObject.swt.assert(.action2(42), isCalled: .twice)
        ///     mockObject.swt.assert(.action2(42), isCalled: 3.times)
        public func assert(
            _ action: Action,
            isCalled expectedCallFrequency: CallFrequency
        ) {
            assertActions(
                where: { $0 == action },
                isCalled: expectedCallFrequency
            )
        }

        /// Asserts that a set of actions meet a certain call frequency criteria based on a condition.
        ///
        /// This version of the function is intended specifically for use in Swift Testing contexts.
        ///
        /// - Parameters:
        ///   - isIncluded: A closure that takes an action and returns a Bool indicating whether the action should be included in the assertion.
        ///   - expectedCallFrequency: The expected frequency of the filtered action calls.
        ///
        /// Example Usage:
        ///
        ///     mockObject.swt.assertActions(where: { $0 == .action1 }, isCalled: .once)
        ///     mockObject.swt.assertActions(where: { $0 == .action2(42) }, isCalled: .twice)
        ///     mockObject.swt.assertActions(where: { $0 == .action2(42) }, isCalled: 3.times)
        public func assertActions(
            where isIncluded: (Action) -> Bool,
            isCalled expectedCallFrequency: CallFrequency
        ) {
            #expect(mockObject.actions.filter { isIncluded($0) }.count == expectedCallFrequency)
        }

        /// Asserts that the total number of recorded actions matches the expected count.
        ///
        /// This version of the function is intended specifically for use in Swift Testing contexts.
        ///
        /// - Parameters:
        ///   - expectedActionsCallFrequency: The expected number of total actions.
        ///
        /// Example Usage:
        ///
        ///     mockObject.swt.assertActionsCalled(.once)
        ///     mockObject.swt.assertActionsCalled(.twice)
        ///     mockObject.swt.assertActionsCalled(3.times)
        public func assertActionsCalled(
            _ expectedActionsCallFrequency: CallFrequency
        ) {
            #expect(mockObject.actions.count == expectedActionsCallFrequency)
        }

        /// Asserts that the recorded actions match the expected actions in the given order.
        ///
        /// This version of the function is intended specifically for use in Swift Testing contexts.
        ///
        /// - Parameters:
        ///   - expectedActions: The expected array of actions.
        ///
        /// Example Usage:
        ///
        ///     mockObject.swt.assertActions(shouldBe: [.action1, .action2(42)])
        public func assertActions(shouldBe expectedActions: [Action]) {
            #expect(mockObject.actions == expectedActions)
        }
    }
    
    /// Provides access to the Swift Testing (SWT) namespace.
    ///
    /// The `swt` property is used to access test-specific assertions designed for Swift Testing contexts,
    /// allowing verification of mock object behavior (e.g., action frequency and conditions) in your test cases.
    ///
    /// Example Usage:
    ///
    ///     mockObject.swt.assert(.action1, isCalled: .once)
    ///     mockObject.swt.assertActions(where: { $0 == .action2(42) }, isCalled: .twice)
    ///     mockObject.swt.assertActionsCalled(3.times)
    public var swt: SWT {
        return SWT(mockObject: self)
    }
}
