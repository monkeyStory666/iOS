// Copyright © 2023 MEGA Limited. All rights reserved.

import UIKit

public protocol GenerateDefaultAvatarUseCaseProtocol {
    func defaultAvatarForCurrentUser() async throws -> UIImage
}

public struct GenerateDefaultAvatarUseCase: GenerateDefaultAvatarUseCaseProtocol {
    public static let defaultPrimaryColor = "#FF5267"
    public static let defaultSecondaryColor = "#FF002B"

    private let generator: any DefaultAvatarGenerating
    private let languageDetector: any RightToLeftLanguageDetecting
    private let fetchAccountUseCase: any FetchAccountUseCaseProtocol
    private let backgroundColorRepo: any DefaultAvatarBackgroundColorRepositoryProtocol

    public init(
        generator: some DefaultAvatarGenerating,
        languageDetector: some RightToLeftLanguageDetecting,
        fetchAccountUseCase: some FetchAccountUseCaseProtocol,
        backgroundColorRepo: some DefaultAvatarBackgroundColorRepositoryProtocol
    ) {
        self.generator = generator
        self.languageDetector = languageDetector
        self.fetchAccountUseCase = fetchAccountUseCase
        self.backgroundColorRepo = backgroundColorRepo
    }

    public func defaultAvatarForCurrentUser() async throws -> UIImage {
        let account = try await fetchAccountUseCase.fetchAccount()
        let backgroundColors = await backgroundColors()

        return try await generator.generate(
            initials: initials(for: account.fullName),
            backgroundColor: backgroundColors.primary,
            secondaryBackgroundColor: backgroundColors.secondary,
            isRightToLeftLanguage: languageDetector.isRightToLeftLanguage()
        )
    }

    private func backgroundColors() async -> (
        primary: String,
        secondary: String
    ) {
        let primary = try? await backgroundColorRepo.fetchBackgroundColor()
        let secondary = try? await backgroundColorRepo.fetchSecondaryBackgroundColor()

        guard let primary, let secondary else {
            return (Self.defaultPrimaryColor, Self.defaultSecondaryColor)
        }

        return (primary, secondary)
    }

    private func initials(for accountName: String) -> String {
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.first?.uppercased() ?? ""
    }
}
