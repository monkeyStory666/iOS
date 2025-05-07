// Copyright © 2024 MEGA Limited. All rights reserved.

import Testing
@testable import MEGAPreference

struct PreferenceWrapperTests {
    @Test func preferenceWrapper_whenPreferenceUseCaseHasValue_shouldUsePreferenceUseCaseValue() {
        let values: [String: Bool] = [MockPreferenceKey.mockKey.rawValue: false]
        let mockPreferenceUseCase = MockPreferenceUseCase(dict: values)

        let sut = ObjectWithPreferenceWrapper(preferenceUseCase: mockPreferenceUseCase)

        #expect(sut.sampleValue == false)
    }

    @Test func preferenceWrapper_whenPreferenceUseCaseHasNoValue_shouldUseDefaultValue() {
        let mockPreferenceUseCase = MockPreferenceUseCase()
        let sut = ObjectWithPreferenceWrapper(preferenceUseCase: mockPreferenceUseCase)

        #expect(sut.sampleValue)
    }

    @Test func preferenceWrapper_whenSetsValue_shouldSetPreferenceUseCaseValue() {
        let mockPreferenceUseCase = MockPreferenceUseCase()
        let sut = ObjectWithPreferenceWrapper(preferenceUseCase: mockPreferenceUseCase)

        sut.sampleValue = false

        #expect(mockPreferenceUseCase.dict[MockPreferenceKey.mockKey.rawValue] != nil)
    }
}

extension PreferenceWrapperTests {
    enum MockPreferenceKey: String, PreferenceKeyProtocol {
        case mockKey
    }

    final class ObjectWithPreferenceWrapper {
        @PreferenceWrapper(key: MockPreferenceKey.mockKey, defaultValue: true)
        var sampleValue: Bool

        init(preferenceUseCase: some PreferenceUseCaseProtocol) {
            $sampleValue.useCase = preferenceUseCase
        }
    }
}
