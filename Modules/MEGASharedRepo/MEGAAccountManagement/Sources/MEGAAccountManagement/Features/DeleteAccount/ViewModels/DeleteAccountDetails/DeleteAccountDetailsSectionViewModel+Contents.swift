// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASharedRepoL10n
import SwiftUI

public extension DeleteAccountDetailsSectionViewModel {
    static var commonSections: [DeleteAccountDetailsSectionViewModel] { [.cloudDrive, .chat] }

    static var cloudDrive: DeleteAccountDetailsSectionViewModel {
        .init(
            title: SharedStrings.Localizable.DeleteAccount.Details.cloudDriveTitle,
            rows: [
                .init(
                    image: Image("folder", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.filesAndFoldersTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.filesAndFoldersDescription
                ),
                .init(
                    image: Image("photoAlbum", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.photoAlbumsTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.photoAlbumsDescription
                ),
                .init(
                    image: Image("userSquare", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.contactsTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.contactsDescription
                )
            ]
        )
    }

    static var chat: DeleteAccountDetailsSectionViewModel {
        .init(
            title: SharedStrings.Localizable.DeleteAccount.Details.chatsAndMeetingsTitle,
            rows: [
                .init(
                    image: Image("chats", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.chatsTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.chatsDescription
                ),
                .init(
                    image: Image("meetings", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.meetingsTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.meetingsDescription
                )
            ]
        )
    }

    static var appleSubscription: DeleteAccountDetailsSectionViewModel {
        .init(
            title: nil,
            rows: [
                .init(
                    image: Image("note", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.subscriptionTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.appleSubscriptionDescription,
                    isBanner: true
                )
            ]
        )
    }

    static var androidSubscription: DeleteAccountDetailsSectionViewModel {
        .init(
            title: nil,
            rows: [
                .init(
                    image: Image("note", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.subscriptionTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.androidSubscriptionDescription,
                    isBanner: true
                )
            ]
        )
    }

    static var otherPlatformSubscription: DeleteAccountDetailsSectionViewModel {
        .init(
            title: nil,
            rows: [
                .init(
                    image: Image("note", bundle: .module),
                    title: SharedStrings.Localizable.DeleteAccount.Details.subscriptionTitle,
                    description: SharedStrings.Localizable.DeleteAccount.Details.otherPlatformSubscriptionDescription,
                    isBanner: true
                )
            ]
        )
    }
}

