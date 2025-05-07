// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

struct ColoredTextField: UIViewRepresentable {
    @Binding var text: String
    let onSubmit: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<ColoredTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.attributedText = text.coloredText
        textField.delegate = context.coordinator
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.returnKeyType = .next
        return textField
    }

    func makeCoordinator() -> ColoredTextField.Coordinator {
        return Coordinator(text: $text, onSubmit: onSubmit)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        guard uiView.attributedText?.string != text else { return }
        uiView.attributedText = text.coloredText
    }
}

// MARK: - Nested Type

extension ColoredTextField {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        let onSubmit: (() -> Void)?
        
        init(
            text: Binding<String>,
            onSubmit: (() -> Void)?
        ) {
            _text = text
            self.onSubmit = onSubmit
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let currentText = textField.text as? NSString else { return true }

            let positionOriginal = textField.beginningOfDocument
            let cursorLocation = textField.position(from: positionOriginal, offset: (range.location + NSString(string: string).length))

            let newText = currentText.replacingCharacters(in: range, with: string)
            textField.attributedText = newText.coloredText
            text = newText
            if let cursorLocation {
                textField.selectedTextRange = textField.textRange(from: cursorLocation, to: cursorLocation)
            }
            return false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit?()
            return true
        }
    }
}
