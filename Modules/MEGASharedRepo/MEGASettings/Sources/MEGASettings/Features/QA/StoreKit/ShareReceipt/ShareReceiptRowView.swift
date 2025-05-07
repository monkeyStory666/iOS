// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGAStoreKit
import MEGAUIComponent
import StoreKit
import SwiftUI

public struct ShareReceiptRowView: View {
    @State private var isPresentingShareSheet = false
    @State private var isPresentingAlert: AlertModel?
    @State private var isRefreshing = false
    @State private var receiptURL: URL?

    public init() {}

    public var body: some View {
        button
            .onAppear(perform: refreshReceipt)
            .disabled(isRefreshing)
    }

    @ViewBuilder
    private var button: some View {
        if let receiptURL {
            shareReceiptView(with: receiptURL)
        } else {
            Button {
                isPresentingAlert = AlertModel(
                    title: "No receipt found",
                    message: "Try to make a new purchase or restart the app"
                )
            } label: {
                rowView
            }
            .alert(unwrapModel: $isPresentingAlert)
        }
    }

    @ViewBuilder
    private func shareReceiptView(with receipt: URL) -> some View {
        if #available(iOS 16, *) {
            ShareLink(items: [receipt]) {
                rowView
            }
        } else {
            Button {
                isPresentingShareSheet.toggle()
            } label: {
                rowView
            }
            #if targetEnvironment(macCatalyst)
            .fullScreenCover(isPresented: $isPresentingShareSheet) {
                ZStack(alignment: .center) {
                    ShareSheetView(
                        itemsToShare: [receipt],
                        didDismiss: { _ in }
                    )
                    ProgressView()
                }
            }
            #else
            .sheet(isPresented: $isPresentingShareSheet) {
                ShareSheetView(
                    itemsToShare: [receipt],
                    didDismiss: { _ in }
                )
            }
            #endif
        }
    }

    private func refreshReceipt() {
        withAnimation {
            isRefreshing = true
        }

        Task(priority: .userInitiated) {
            let receipt = try? await StoreKitReceiptDelegate.fetchLocalReceipt()
            receiptURL = try? receipt?.saveStringToFile()
            withAnimation {
                isRefreshing = false
            }
        }
    }

    private var rowView: some View {
        MEGAList(title: "Share StoreKit Receipt")
            .borderEdges(.vertical)
            .leadingImage(icon: Image(systemName: "square.and.arrow.up"))
            .replaceTrailingView { refreshButton }
            .footerText("""
            Use this button to when you need to share the receipt to API team for debugging and investigation purposes
            Tap the refresh button to ensure you're getting the latest receipt.
            """)
    }

    @ViewBuilder
    private var refreshButton: some View {
        if isRefreshing {
            ProgressView()
        } else {
            Button {
                refreshReceipt()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

private extension String {
    func saveStringToFile(
        fileName: String = "receipt-\(Date.currentTimestamp).txt",
        fileManager: FileManager = .default
    ) throws -> URL {
        let fullFileName = fileName.hasSuffix(".txt") ? fileName : "\(fileName).txt"
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent(fullFileName)

        do {
            try write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw NSError(
                domain: "FileManagerService", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to write file: \(error.localizedDescription)"]
            )
        }

        return fileURL
    }
}

private extension Date {
    static var currentTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmm"
        return dateFormatter.string(from: Date())
    }
}
