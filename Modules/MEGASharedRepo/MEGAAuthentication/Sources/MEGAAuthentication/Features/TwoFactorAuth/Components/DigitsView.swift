// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import MEGASwift
import MEGAUIComponent
import SwiftUI

struct DigitsView: View {
    enum State {
        case normal
        case editing(index: Int)
        case errorEditing(index: Int)
        case success
        case error
    }

    let passcode: Passcode
    let state: State

    var body: some View {
        HStack(spacing: TokenSpacing._5) {
            ForEach(0 ..< passcode.maxCount, id: \.self) { index in
                ZStack {
                    if case let .editing(editingIndex) = state, editingIndex == index {
                        CursorView()
                    } else if case let .errorEditing(errorIndex) = state, errorIndex == index {
                        CursorView(isError: true)
                    }

                    DigitView(digit: digit(at: index), state: digitViewState(at: index))
                }
            }
        }
    }

    private func digitViewState(at index: Int) -> DigitView.State {
        switch state {
        case .normal:
            .normal
        case let .editing(editingIndex):
            editingIndex == index ? .editing : .normal
        case let .errorEditing(errorIndex):
            errorIndex == index ? .errorEditing : .error
        case .success:
            .success
        case .error:
            .error
        }
    }

    private func digit(at index: Int) -> String {
        index < passcode.count
            ? passcode[index].digitString
            : ""
    }
}

private struct DigitView: View {
    enum State {
        case normal
        case editing
        case errorEditing
        case success
        case error
    }

    let digit: String
    let state: State

    var body: some View {
        Text(digit)
            .font(.callout)
            .frame(height: 49)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(strokeColor())
            }
    }

    private func strokeColor() -> Color {
        switch state {
        case .normal:
            TokenColors.Border.strong.swiftUI
        case .editing:
            TokenColors.Border.strongSelected.swiftUI
        case .success:
            TokenColors.Support.success.swiftUI
        case .error, .errorEditing:
            TokenColors.Support.error.swiftUI
        }
    }
}

struct DigitsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DigitsView(passcode: Passcode(values: [2, 3, 7, 8, 0, 1]), state: .normal)
                .padding(.horizontal, 10)
            DigitsView(passcode: Passcode(values: [2, 3, 7]), state: .editing(index: 3))
                .padding(.horizontal, 20)
            DigitsView(passcode: Passcode(values: [2, 3, 7, 8, 0, 1]), state: .success)
                .padding(.horizontal, 5)
            DigitsView(passcode: Passcode(values: [2, 3, 7, 8, 0, 1]), state: .error)
                .padding(.horizontal, 30)
        }
    }
}
