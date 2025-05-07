import MEGADesignToken
import MEGAPresentation
import MEGASDKRepo
import MEGAUIComponent
import SwiftUI

public struct ChangeSDKEnvironmentRowView: View {
    @StateObject private var viewModel: ChangeSDKEnvironmentRowViewModel

    public init(
        viewModel: @autoclosure @escaping () -> ChangeSDKEnvironmentRowViewModel = ChangeSDKEnvironmentRowViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        MEGAList(contentBorderEdges: .vertical) {
            Picker(
                "Change SDK Environment",
                selection: Binding(get: {
                    viewModel.environment
                }, set: { newEnvironment in
                    Task { await viewModel.select(newEnvironment) }
                })
            ) {
                ForEach(SDKEnvironment.allCases, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
            .tint(TokenColors.Text.primary.swiftUI)
            .navigationLinkPickerStyle()
            .padding(.vertical, 16)
        }
        .trailingChevron()
    }
}
