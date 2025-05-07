// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

struct InvisibleTextField: View {
    @Binding var disabled: Bool
    @Binding var text: String
    @FocusState.Binding var hasFocus: Bool
    let onPasscodeUpdate: (String) -> Void

    var body: some View {
        TextField("", text: $text)
            .tint(.clear)
            .colorMultiply(.clear)
            .foregroundStyle(.clear)
            .keyboardType(.numberPad)
        #if !targetEnvironment(macCatalyst)
            .textContentType(.oneTimeCode)
        // This is a fix for not displaying autofill on earlier macOS versions
        // Context: https://testrail.systems.mega.nz/index.php?/tests/view/15708477
        #else
            .textContentType(.username)
        #endif
            .autocorrectionDisabled()
            .onTapGesture {
                hasFocus = true
            }
            .onChange(of: text) {
                onPasscodeUpdate($0)
            }
            .disabled(disabled)
            .focused($hasFocus)
            .accessibilityHidden(true)
    }
}
