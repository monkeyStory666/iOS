// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import MEGAStoreKit
import SwiftUI

public struct SimulateAppStorePriceChangeRowView: View {
    @StateObject private var viewModel: SimulateAppStorePriceChangeRowViewModel

    public init(
        viewModel: @autoclosure @escaping () -> SimulateAppStorePriceChangeRowViewModel = SimulateAppStorePriceChangeRowViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationLink {
            VStack {
                ForEach(Array(viewModel.cachedAppStorePrice), id: \.key) { cachedPrice in
                    AppStorePriceCacheRowView(key: cachedPrice.key, viewModel: viewModel)
                }
            }
            .navigationTitle("App Store Price Cache Settings")
            .pageBackground(alignment: .top)
        } label: {
            MEGAList(title: "App Store Price Cache Settings")
                .trailingChevron()
                .borderEdges(.vertical)
        }
        .task { await viewModel.onAppear() }
    }

    private var cachedPrices: String {
        if viewModel.cachedAppStorePrice.isEmpty {
            "No cached prices"
        } else {
            viewModel.cachedAppStorePrice.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        }
    }
}

struct AppStorePriceCacheRowView: View {
    @State var showingEditAlert = false
    @State var newValue: String

    let key: String

    @ObservedObject var viewModel: SimulateAppStorePriceChangeRowViewModel

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase

    init(
        key: String,
        viewModel: SimulateAppStorePriceChangeRowViewModel
    ) {
        self.key = key
        self.viewModel = viewModel
        self._newValue = State(
            initialValue: viewModel.priceOverrides[key]
                ?? viewModel.cachedAppStorePrice[key]
                ?? "N/A"
        )
    }

    var body: some View {
        Button {
            showingEditAlert = true
        } label: {
            MEGAList(
                title: key,
                subtitle: {
                    if let overriddenPrice = viewModel.priceOverrides[key] {
                        return "\(overriddenPrice) (From cached price: \(viewModel.cachedAppStorePrice[key] ?? "-"))"
                    } else if let cachedPrice = viewModel.cachedAppStorePrice[key] {
                        return "\(cachedPrice)"
                    } else {
                        return "N/A"
                    }
                }()
            )
            .trailingChevron()
            .borderEdges(.vertical)
            .contentShape(Rectangle())
        }
        .alert("Enter overridden price", isPresented: $showingEditAlert) {
            TextField(
                "\(key)",
                text: $newValue
            )
            .keyboardType(.numbersAndPunctuation)
            Button("Cancel", role: .cancel) {}
            Button("Confirm", action: submit)
            Button("Remove Override", role: .destructive, action: removeOverride)
        }
    }

    private func submit() {
        viewModel.updatePriceOverride(for: key, with: newValue)
    }

    private func removeOverride() {
        viewModel.updatePriceOverride(for: key, with: nil)
    }
}
