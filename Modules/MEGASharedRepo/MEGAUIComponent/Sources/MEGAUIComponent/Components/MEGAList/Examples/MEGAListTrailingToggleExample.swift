// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

#Preview {
    struct MEGAListTrailingToggleExample: View {
        @State var state: MEGAToggle.State = .off
        @State var isDisabled = false

        var body: some View {
            List {
                Section("Preview") {
                    MEGAListPreview()
                        .replaceTrailingView {
                            MEGAToggle(
                                state: state,
                                isDisabled: isDisabled,
                                toggleAction: togglingAction
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
                    Picker("State", selection: $state) {
                        Text("On").tag(MEGAToggle.State.on)
                        Text("Off").tag(MEGAToggle.State.off)
                        Text("Toggling On").tag(MEGAToggle.State.togglingOn)
                        Text("Toggling Off").tag(MEGAToggle.State.togglingOff)
                    }
                    Toggle("Disabled", isOn: $isDisabled)
                }
            }
            .listStyle(GroupedListStyle())
        }

        private func togglingAction(_ state: MEGAToggle.State) {
            if case .on = state {
                toggle(transitionState: .togglingOff, finalState: .off)
            } else if case .off = state {
                toggle(transitionState: .togglingOn, finalState: .on)
            }
        }

        private func toggle(
            transitionState: MEGAToggle.State,
            finalState: MEGAToggle.State
        ) {
            withAnimation {
                self.state = transitionState
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1,
                    execute: {
                        self.state = finalState
                    }
                )
            }
        }
    }

    return MEGAListTrailingToggleExample()
}
