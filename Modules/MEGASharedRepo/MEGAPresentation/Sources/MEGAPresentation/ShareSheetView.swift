// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI
import UIKit

public struct ShareSheetView: UIViewControllerRepresentable {
    let itemsToShare: [URL]
    var didDismiss: (_ completed: Bool) -> Void = { _ in }

    public init(itemsToShare: [URL], didDismiss: @escaping (_: Bool) -> Void) {
        self.itemsToShare = itemsToShare
        self.didDismiss = didDismiss
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    #if targetEnvironment(macCatalyst)
    public func makeUIViewController(context: Context) -> UIViewController {
        let picker = UIDocumentPickerViewController(forExporting: itemsToShare, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: ShareSheetView

        init(_ parent: ShareSheetView) {
            self.parent = parent
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.didDismiss(true)
        }

        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.didDismiss(false)
        }
    }
    #else
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareSheetView>
    ) -> UIViewController {
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { _, isShared, _, _ in
            didDismiss(isShared)
        }
        return activityVC
    }
    #endif
}
