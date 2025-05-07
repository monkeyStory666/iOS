// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol SnackbarDisplaying {
    func display(_ snackbar: SnackbarEntity)
}

public final class SnackbarDisplayer: SnackbarDisplaying {
    private let updateSnackbarInViewModel: (SnackbarEntity?, _ completion: (() -> Void)?) -> Void
    private let serialQueue = DispatchQueue(label: "nz.mega.SnackbarDisplayer")

    private var isDisplayingSnackbar: Bool = false

    private var _queue: [SnackbarEntity] = []
    private var queue: [SnackbarEntity] {
        get { _queue }
        set {
            serialQueue.sync(flags: .barrier) {
                _queue = newValue
                displayNextSnackbarIfNeeded()
            }
        }
    }

    init(updateSnackbarInViewModel: @escaping (SnackbarEntity?, _ completion: (() -> Void)?) -> Void) {
        self.updateSnackbarInViewModel = updateSnackbarInViewModel
    }

    public init(viewModel: SecondarySceneViewModel) {
        self.updateSnackbarInViewModel = { [weak viewModel] snackbarEntity, completion in
            DispatchQueue.main.async {
                viewModel?.snackbarEntity = snackbarEntity
                viewModel?.objectWillChange.send()
                completion?()
            }
        }
    }

    public func display(_ snackbar: SnackbarEntity) {
        guard queue.last != snackbar else { return }

        queue.append(snackbar)
    }

    private func displayNextSnackbarIfNeeded() {
        guard !isDisplayingSnackbar, let nextSnackbar = queue.first else { return }

        displaySnackbarInView(SnackbarEntity(
            text: nextSnackbar.text,
            showtime: nextSnackbar.showtime,
            actionLabel: nextSnackbar.actionLabel,
            action: nextSnackbar.action,
            onDismiss: { [weak self] in
                nextSnackbar.onDismiss?()
                self?.removeSnackbarFromView(nextSnackbar) {
                    _ = self?.queue.removeFirst(where: { $0 == nextSnackbar })
                }
            }
        ))
    }

    private func displaySnackbarInView(_ snackbarEntity: SnackbarEntity) {
        isDisplayingSnackbar = true
        updateSnackbarInViewModel(snackbarEntity, nil)
    }

    private func removeSnackbarFromView(
        _ snackbarToRemove: SnackbarEntity,
        completion: (() -> Void)?
    ) {
        isDisplayingSnackbar = false
        updateSnackbarInViewModel(nil, completion)
    }
}

extension Array {
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
}
