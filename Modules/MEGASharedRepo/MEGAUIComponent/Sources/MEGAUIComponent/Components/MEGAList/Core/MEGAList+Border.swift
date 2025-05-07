// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

// MARK: - Convenience Initializer with Title and Subtitle

public extension MEGAList {
    func borderEdges(_ edges: Edge.Set) -> Self {
        .init(
            contentBorderEdges: edges,
            padding: padding,
            contentView: contentView,
            headerView: headerView,
            footerView: footerView,
            leadingView: leadingView,
            trailingView: trailingView
        )
    }
}

#Preview {
    struct MEGAListBorderEdgePreview: View {
        @State var borderEdges: Edge.Set = .vertical

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .borderEdges(borderEdges)
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                        .padding(.vertical, 16)
                }

                Section("Configuration") {
                    Toggle(
                        "Show border",
                        isOn: Binding(
                            get: { !borderEdges.isEmpty },
                            set: { isOn in
                                borderEdges = isOn ? .vertical : []
                            }
                        )
                    )
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListBorderEdgePreview()
}
