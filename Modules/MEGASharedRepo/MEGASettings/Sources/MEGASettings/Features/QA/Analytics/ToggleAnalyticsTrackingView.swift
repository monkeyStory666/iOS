// Copyright © 2024 MEGA Limited. All rights reserved.

#if !targetEnvironment(macCatalyst)
import MEGAAnalytics
import MEGADesignToken
import MEGAUIComponent
import MEGAInfrastructure
import MEGALogger
import SwiftUI

public struct ToggleAnalyticsTrackingView: View {
    @State private var option: AnalyticsQASettingsOption

    @StateObject private var tracker: AnalyticsTrackerDecorator

    private let featureFlagsUseCase: any FeatureFlagsUseCaseProtocol
    private let loggingUseCase: any LoggingUseCaseProtocol
    private let appCode: Int

    public init(
        tracker: @autoclosure @escaping () -> AnalyticsTrackerDecorator,
        appCode: Int,
        featureFlagsUseCase: any FeatureFlagsUseCaseProtocol = DependencyInjection.featureFlagsUseCase,
        loggingUseCase: some LoggingUseCaseProtocol = MEGALogger.DependencyInjection.loggingUseCase
    ) {
        self.featureFlagsUseCase = featureFlagsUseCase
        self.loggingUseCase = loggingUseCase
        self.appCode = appCode
        self._tracker = StateObject(wrappedValue: tracker())
        self._option = State(
            initialValue: featureFlagsUseCase.get(for: .trackAnalyticsFlag) ?? .disabled
        )
    }

    public var body: some View {
        NavigationLink {
            AnalyticsQASettingsView(
                tracker: tracker,
                option: Binding(
                    get: { option },
                    set: {
                        self.option = $0
                        featureFlagsUseCase.set($0, for: .trackAnalyticsFlag)
                    }
                ),
                appCode: appCode
            )
            .pageBackground(alignment: .top)
        } label: {
            MEGAList(title: "Analytics QA Settings")
                .borderEdges(.vertical)
                .trailingChevron()
                .contentShape(Rectangle())
        }
    }

    private func toggle(_ option: AnalyticsQASettingsOption) {
        self.option = option
        self.featureFlagsUseCase.set(
            option,
            for: .trackAnalyticsFlag
        )
    }
}

struct AnalyticsQASettingsView: View {
    @ObservedObject var tracker: AnalyticsTrackerDecorator

    @State private var searchText = ""
    @Binding var option: AnalyticsQASettingsOption

    let appCode: Int

    var body: some View {
        VStack(spacing: 16) {
            MEGAList(title: "Track Analytics Event")
                .borderEdges(.vertical)
                .replaceTrailingView {
                    MEGAToggle(
                        state: .init(isOn: option.isEnabled),
                        toggleAction: { state in
                            switch state {
                            case .on: option = .disabled
                            case .off: option = .enabled(displayLimit: 50)
                            default: break
                            }
                        }
                    )
                }
                .footerText("""
                This setting needs to be enabled when testing Analytics tracking and disabled when not testing it.
                This is so that we can avoid data pollution on our stats.
                """)
            if option.isEnabled {
                MEGAList(title: "Events Display Limit")
                    .borderEdges(.vertical)
                    .replaceTrailingView {
                        Stepper(
                            value: Binding(
                                get: { option.displayLimit ?? 0 },
                                set: {
                                    guard case .enabled = option else { return }
                                    option = .enabled(displayLimit: $0)
                                }
                            ),
                            in: 10...100
                        ) {
                            Text("\(option.displayLimit ?? 0)")
                        }
                    }
                    .footerText("""
                    This setting set how many events you want to see in the log below.
                    """)
                MEGAList {
                    NavigationView {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(
                                    Array(
                                        tracker.eventsSent.enumerated()
                                            .filter { shouldQuery(for: $0.element.event) }
                                            .reversed()
                                    ),
                                    id: \.offset
                                ) { _, element in
                                    VStack(spacing: .zero) {
                                        MEGAList(
                                            title: title(for: element.event),
                                            subtitle: subtitle(for: element.event)
                                        )
                                        .replaceTrailingView {
                                            Text(String(describing: element.date.formatted(date: .omitted, time: .standard)))
                                                .font(.footnote)
                                                .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                                        }
                                        .borderEdges(.bottom)
                                        if let detailsText = details(for: element.event) {
                                            Text(detailsText)
                                                .font(.footnote)
                                                .foregroundStyle(TokenColors.Text.secondary.swiftUI)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(backgroundColor(for: element.event).opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(backgroundColor(for: element.event), lineWidth: 1)
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .pageBackground(alignment: .top)
                        .searchable(text: $searchText, placement: .toolbar)
                        .navigationTitle("Recently Sent Events")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .borderEdges(.vertical)
                .setPadding(.zero)
            }
        }
    }

    private func shouldQuery(for event: any AnalyticsEventEntityProtocol) -> Bool {
        guard !searchText.isEmpty else { return true }

        return title(for: event).contains(searchText) || subtitle(for: event).contains(searchText)
    }

    private func title(for event: any AnalyticsEventEntityProtocol) -> String {
        String(describing: event.identifier?.eventName ?? "N/A")
    }

    private func subtitle(for event: any AnalyticsEventEntityProtocol) -> String {
        let iosPlatformCode = "4"
        let eventType = EventIdentifierType(from: event.identifier)?.rawValue.toString ?? "?"
        let uniqueIdentifier = String(format: "%03d", event.identifier?.uniqueIdentifier ?? 0)

        return "\(iosPlatformCode)\(appCode)\(eventType)\(uniqueIdentifier)"
    }

    private func details(for event: any AnalyticsEventEntityProtocol) -> String? {
        guard
            let start = event.rawValue.firstIndex(of: "("),
            let end = event.rawValue.lastIndex(of: ")"),
            start < end
        else { return nil }

        let innerText = event.rawValue[event.rawValue.index(after: start)..<end]
        return String(innerText)
    }

    private func backgroundColor(for event: any AnalyticsEventEntityProtocol) -> Color {
        switch EventIdentifierType(from: event.identifier) {
        case .screenView:
            TokenColors.Indicator.blue.swiftUI
        case .tabSelected:
            TokenColors.Indicator.green.swiftUI
        case .buttonPressed:
            TokenColors.Indicator.orange.swiftUI
        case .dialogDisplayed:
            TokenColors.Indicator.indigo.swiftUI
        case .navigationAction:
            TokenColors.Indicator.magenta.swiftUI
        case .menuItemSelected:
            TokenColors.Indicator.pink.swiftUI
        case .notification:
            TokenColors.Indicator.yellow.swiftUI
        case .general:
            TokenColors.Indicator.yellow.swiftUI
        case .itemSelected:
            TokenColors.Indicator.pink.swiftUI
        default: .secondary
        }
    }
}

private extension Int {
    var toString: String {
        String(describing: self)
    }
}
#endif
