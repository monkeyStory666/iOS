// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import Testing
import UniformTypeIdentifiers

final class CopyToClipboardTests {
    private(set) var valueSetCalls = [(String, String)]()
    private(set) var stringSetCalls = [String]()

    @Test(
        arguments: [
            "Hello, World!",
            "Test",
            "123"
        ]
    ) func copy_shouldSetValueAndString(
        text: String
    ) {
        let sut = makeSUT()

        sut.copy(text: text)

        #expect(valueSetCalls.count == 1)
        #expect(valueSetCalls[0].0 == text)
        #expect(valueSetCalls[0].1 == UTType.plainText.identifier)
        #expect(stringSetCalls == [text])
    }

    // MARK: - Test Helpers

    private func makeSUT() -> CopyToClipboard {
        CopyToClipboard(
            setValue: {
                self.valueSetCalls.append(($0, $1))
            },
            setString: {
                self.stringSetCalls.append($0)
            }
        )
    }
}
