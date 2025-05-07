// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGASharedRepoL10n

public enum AccountPlanTypeEntity: Codable, Sendable {
    case free
    case starter
    case basic
    case essential
    case proI
    case proII
    case proIII
    case lite
    case business
    case proFlexi
    case feature

    public var displayName: String {
        switch self {
        case .free:
            SharedStrings.Localizable.Subscriptions.FreePlan.title
        case .starter:
            "MEGA Starter"
        case .basic:
            "MEGA Basic"
        case .essential:
            "MEGA Essential"
        case .proI:
            "Pro I"
        case .proII:
            "Pro II"
        case .proIII:
            "Pro III"
        case .lite:
            "Pro Lite"
        case .business:
            "Business"
        case .proFlexi:
            "Pro Flexi"
        case .feature:
            ""
        }
    }

    public var isAccountPlan: Bool {
        switch self {
        case .feature:
            return false
        default:
            return true
        }
    }
}
