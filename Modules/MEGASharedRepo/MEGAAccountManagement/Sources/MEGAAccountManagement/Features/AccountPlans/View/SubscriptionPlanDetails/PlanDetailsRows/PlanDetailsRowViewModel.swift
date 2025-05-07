// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASharedRepoL10n
import MEGAUIComponent
import SwiftUI

public struct PlanDetailsRowViewModel: Identifiable {
    public struct Feature: Identifiable {
        public var id: String { name }
        public let icon: Image
        public let name: String

        public init(
            icon: Image,
            name: String
        ) {
            self.icon = icon
            self.name = name
        }
    }

    public var id: String { name }

    public let name: String
    public let isFeaturePlan: Bool
    public let isTrial: Bool
    public let expiryDate: TimeInterval?
    public let renewDate: TimeInterval?
    public let isExpiredProFlexi: Bool
    public let price: String?
    public let footer: String?
    public let now: Date

    public let features: [Feature]
    public let buttons: () -> [MEGAButton]

    private let dateFormatter: DateFormatter

    public init(
        name: String,
        isFeaturePlan: Bool = false,
        isTrial: Bool = false,
        expiryDate: TimeInterval? = nil,
        renewDate: TimeInterval? = nil,
        isExpiredProFlexi: Bool = false,
        price: String? = nil,
        buttonText: String? = nil,
        features: [Feature] = [],
        footer: String? = nil,
        dateFormatter: DateFormatter = .init(),
        buttonAction: (() -> Void)? = nil,
        now: Date = Date()
    ) {
        self.init(
            name: name,
            isFeaturePlan: isFeaturePlan,
            isTrial: isTrial,
            expiryDate: expiryDate,
            renewDate: renewDate,
            isExpiredProFlexi: isExpiredProFlexi,
            price: price,
            features: features,
            buttons: {
                if let buttonText { [MEGAButton(buttonText, action: buttonAction)] }
                else { [] }
            }(),
            footer: footer,
            dateFormatter: dateFormatter,
            now: now
        )
    }

    public init(
        name: String,
        isFeaturePlan: Bool = false,
        isTrial: Bool = false,
        expiryDate: TimeInterval? = nil,
        renewDate: TimeInterval? = nil,
        isExpiredProFlexi: Bool = false,
        price: String? = nil,
        features: [Feature] = [],
        buttons: @escaping @autoclosure () -> [MEGAButton] = [],
        footer: String? = nil,
        dateFormatter: DateFormatter = .init(),
        now: Date = Date()
    ) {
        self.name = name
        self.isFeaturePlan = isFeaturePlan
        self.isTrial = isTrial
        self.expiryDate = expiryDate
        self.renewDate = renewDate
        self.isExpiredProFlexi = isExpiredProFlexi
        self.price = price
        self.features = features
        self.buttons = buttons
        self.footer = footer
        self.dateFormatter = dateFormatter
        self.now = now
    }

    public var displayName: String {
        AccountPlanDisplayNameEntity.displayName(
            planName: name,
            isFeaturePlan: false,
            isTrial: isTrial
        )
    }

    public var dateString: String? {
        AccountPlanDisplayNameEntity.displaySubtitle(
            isTrial: isTrial,
            renewDate: renewDate,
            expiryDate: expiryDate,
            now: now,
            dateFormatter: dateFormatter
        )
    }
}
