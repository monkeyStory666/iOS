import Testing
import MEGASwift

struct CharacterExtensionsTests {
    @Test func isEmoji_withSimpleEmoji_shouldReturnTrue() {
        // Test simple emojis
        #expect(Character("😀").isEmoji, "Expected 😀 to be recognized as an emoji")
        #expect(Character("🎉").isEmoji, "Expected 🎉 to be recognized as an emoji")
    }

    @Test func isEmoji_withCombinedEmoji_shouldReturnTrue() {
        // Test combined emojis
        #expect(Character("👍🏿").isEmoji, "Expected 👍🏿 to be recognized as an emoji")
        #expect(Character("👩‍👩‍👧‍👦").isEmoji, "Expected 👩‍👩‍👧‍👦 to be recognized as an emoji")
    }

    @Test func isEmoji_withNonEmojiCharacters_shouldReturnFalse() {
        // Test non-emoji characters
        #expect(Character("a").isEmoji == false, "Expected 'a' not to be recognized as an emoji")
        #expect(Character("1").isEmoji == false, "Expected '1' not to be recognized as an emoji")
        #expect(Character(" ").isEmoji == false, "Expected ' ' not to be recognized as an emoji")
    }
}
