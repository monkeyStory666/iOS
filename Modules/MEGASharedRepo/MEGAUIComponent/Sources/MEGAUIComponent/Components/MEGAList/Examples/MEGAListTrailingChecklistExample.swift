// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

#Preview {
    struct MEGAListTrailingChecklistExample: View {
        @State var state: MEGAChecklist.State = .default
        @State var isChecked = false

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .replaceTrailingView {
                            MEGAChecklist(
                                state: state,
                                isChecked: $isChecked
                            )
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                }

                Section("Configuration") {
                    Toggle("Checked", isOn: $isChecked)
                    Picker("State", selection: $state) {
                        Text("Default").tag(MEGAChecklist.State.default)
                        Text("Hover").tag(MEGAChecklist.State.hover)
                        Text("Focus").tag(MEGAChecklist.State.focus)
                        Text("Error").tag(MEGAChecklist.State.error)
                        Text("Disabled").tag(MEGAChecklist.State.disabled)
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }

    return MEGAListTrailingChecklistExample()
}
