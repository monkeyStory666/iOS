// Copyright © 2023 MEGA Limited. All rights reserved.

import UIKit
import UniformTypeIdentifiers

public protocol CopyToClipboardProtocol {
    func copy(text: String)
}

public struct CopyToClipboard: CopyToClipboardProtocol {
    private let setValue: (String, String) -> Void
    private let setString: (String) -> Void

    /// Initializes a `CopyToClipboard` instance with the required clipboard functionality.
    ///
    /// - Note: This initializer requires proper injection of clipboard functionality, such as `UIPasteboard`.
    ///
    /// The correct injection for production use is:
    /// ```
    /// CopyToClipboard(
    ///     setValue: UIPasteboard.general.setValue,
    ///     setString: { UIPasteboard.general.string = $0 }
    /// )
    /// ```
    public init(
        setValue: @escaping (String, String) -> Void,
        setString: @escaping (String) -> Void
    ) {
        self.setValue = setValue
        self.setString = setString
    }

    public func copy(text: String) {
        setValue(text, UTType.plainText.identifier)
        setString(text)
    }
}
