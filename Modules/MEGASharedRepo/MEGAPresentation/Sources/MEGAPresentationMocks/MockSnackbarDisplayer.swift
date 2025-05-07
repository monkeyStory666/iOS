// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGATest

public final class MockSnackbarDisplayer: MockObject<MockSnackbarDisplayer.Action>, SnackbarDisplaying {
    public enum Action: Equatable {
        case display(SnackbarEntity)
    }

    public func display(_ snackbar: SnackbarEntity) {
        actions.append(.display(snackbar))
    }

    public func simulateTappingSnackbarAction(for index: Int = 0) {
        guard actions.count > index else { return }

        if case .display(let snackbar) = actions[index] {
            snackbar.action?()
        }
    }

    public func simulateSnackbarDismiss(for index: Int = 0) {
        guard actions.count > index else { return }

        if case .display(let snackbar) = actions[index] {
            snackbar.onDismiss?()
        }
    }
}
