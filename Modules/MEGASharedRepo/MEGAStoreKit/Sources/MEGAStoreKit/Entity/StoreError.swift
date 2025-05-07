// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum StoreError: Error {
    /// A catch-all for any non-specific error that might occur on the system's end.
    /// The user should be advised to retry the transaction, and if it persists, to contact support.
    case system(_ errorLocalizedString: String?)

    /// The requested product isn't available in the user's region or country's store.
    /// The user should be informed that the item is not available for their location.
    case notAvailableInRegion

    /// These errors are related to security and validation processes that ensure the transaction
    /// or the app’s certificates are valid. The flow here would be more technical,
    /// likely prompting the user to reinstall the app or update to the latest version.
    case invalid(_ errorLocalizedString: String?)

    /// These are various errors that can occur due to issues like
    /// requesting a quantity of a product that isn't available,
    /// trying to purchase a product that isn't available anymore, or
    /// the user's account being restricted from making purchases.
    case generic(_ errorLocalizedString: String?)

    /// Issues with promotional offers or discounts, likely due to
    /// the offer conditions not being met or an issue with the offer setup.
    /// Users should be informed of the specific issue and potentially offered an alternative.
    case offerInvalid(_ errorLocalizedString: String?)

    /// These are error that are thrown when transaction returns as unverified from StoreKit 2.
    case unverifiedTransaction(_ errorLocalizedString: String?)

    /// Happens when there is no internet connection, or the connection is lost during a transaction.
    /// The user should be prompted to check their internet connection and try again.
    case networkError

    /// The user cancelled the transaction.
    case userCancelled

    /// The user cannot make payments for in-app purchase because of one of the three
    /// conditions:
    ///
    /// - Disabled through parental control in iOS settings
    /// - Disabled by Mobile Device Management (MDM) profile
    /// - Disabled because its using an External Purchase API
    case userCannotMakePayments

    /// These are errors for purchases that is pending some user action and
    /// may succeed in the future. These purchases result will be handled
    /// separately by observing StoreKit transaction updates.
    ///
    /// Note: This error is not properly handled yet because we don't currently
    /// support Ask to Buy feature in App Store.
    case pending
}

extension StoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .system(let errorLocalizedString):
            "System Error: \(String(describing: errorLocalizedString))"
        case .notAvailableInRegion:
            "Not Available In Region"
        case .invalid(let errorLocalizedString):
            "Invalid Error: \(String(describing: errorLocalizedString))"
        case .generic(let errorLocalizedString):
            "Generic Error: \(String(describing: errorLocalizedString))"
        case .offerInvalid:
            "Invalid Offer Error"
        case .unverifiedTransaction(let errorLocalizedString):
            "Unverified Transaction Error: \(String(describing: errorLocalizedString))"
        case .networkError:
            "Network Error"
        case .userCancelled:
            "User Cancelled"
        case .userCannotMakePayments:
            "User Cannot Make Payments"
        case .pending:
            "Purchase Pending"
        }
    }

    public var failureReason: String? {
        switch self {
        case .system(let errorLocalizedString):
            """
            A catch-all for any non-specific error that might occur on the system's end.

            Reason: \(String(describing: errorLocalizedString))
            """
        case .notAvailableInRegion:
            """
            The requested product isn't available in the user's region or country's store.
            """
        case .invalid(let errorLocalizedString):
            """
            These errors are related to security and validation processes that ensure the transaction
            or the app’s certificates are valid.

            Reason: \(String(describing: errorLocalizedString))
            """
        case .generic(let errorLocalizedString):
            """
            Generic error: \(String(describing: errorLocalizedString))
            """
        case .offerInvalid:
            """
            Issues with promotional offers or discounts, likely due to
            the offer conditions not being met or an issue with the offer setup.
            """
        case .unverifiedTransaction(let errorLocalizedString):
            """
            Unverified transaction error: \(String(describing: errorLocalizedString))
            """
        case .networkError:
            """
            Happens when there is no internet connection, or the connection is lost during a transaction.
            """
        case .userCancelled:
            "The user cancelled the transaction."
        case .userCannotMakePayments:
            """
            The user cannot make payments for in-app purchase because of one of the three
            conditions:

            - Disabled through parental control in iOS settings
            - Disabled by Mobile Device Management (MDM) profile
            - Disabled because its using an External Purchase API
            """
        case .pending:
            "Purchase is pending"
        }
    }
}

extension StoreError: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case errorLocalizedString
    }

    // swiftlint:disable:next cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let localizedErrorString = {
            try container.decodeIfPresent(String.self, forKey: .errorLocalizedString)
        }

        switch type {
        case "system":
            self = .system(try localizedErrorString())
        case "notAvailableInRegion":
            self = .notAvailableInRegion
        case "invalid":
            self = .invalid(try localizedErrorString())
        case "generic":
            self = .generic(try localizedErrorString())
        case "offerInvalid":
            self = .offerInvalid(try localizedErrorString())
        case "unverifiedTransaction":
            self = .unverifiedTransaction(try localizedErrorString())
        case "networkError":
            self = .networkError
        case "userCancelled":
            self = .userCancelled
        case "userCannotMakePayments":
            self = .userCannotMakePayments
        case "pending":
            self = .pending
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "Invalid type value"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .system(let errorLocalizedString):
            try container.encode("system", forKey: .type)
            try container.encode(errorLocalizedString, forKey: .errorLocalizedString)
        case .notAvailableInRegion:
            try container.encode("notAvailableInRegion", forKey: .type)
        case .invalid(let errorLocalizedString):
            try container.encode("invalid", forKey: .type)
            try container.encode(errorLocalizedString, forKey: .errorLocalizedString)
        case .generic(let errorLocalizedString):
            try container.encode("generic", forKey: .type)
            try container.encode(errorLocalizedString, forKey: .errorLocalizedString)
        case .offerInvalid(let errorLocalizedString):
            try container.encode("offerInvalid", forKey: .type)
            try container.encode(errorLocalizedString, forKey: .errorLocalizedString)
        case .unverifiedTransaction(let errorLocalizedString):
            try container.encode("unverifiedTransaction", forKey: .type)
            try container.encode(errorLocalizedString, forKey: .errorLocalizedString)
        case .networkError:
            try container.encode("networkError", forKey: .type)
        case .userCancelled:
            try container.encode("userCancelled", forKey: .type)
        case .userCannotMakePayments:
            try container.encode("userCannotMakePayments", forKey: .type)
        case .pending:
            try container.encode("pending", forKey: .type)
        }
    }
}

extension StoreError: Hashable {
    public static func == (lhs: StoreError, rhs: StoreError) -> Bool {
        switch (lhs, rhs) {
        case let (.generic(lhsError), .generic(rhsError)),
             let (.unverifiedTransaction(lhsError), .unverifiedTransaction(rhsError)):
            return lhsError == rhsError
        case (.system, .system),
            (.notAvailableInRegion, .notAvailableInRegion),
            (.invalid, .invalid),
            (.offerInvalid, .offerInvalid),
            (.networkError, .networkError),
            (.userCancelled, .userCancelled),
            (.userCannotMakePayments, .userCannotMakePayments),
            (.pending, .pending):
            return true
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .system:
            hasher.combine("system")
        case .notAvailableInRegion:
            hasher.combine("notAvailableInRegion")
        case .invalid:
            hasher.combine("invalid")
        case .generic(let errorLocalizedString):
            hasher.combine("generic")
            hasher.combine(errorLocalizedString)
        case .offerInvalid:
            hasher.combine("offerInvalid")
        case .unverifiedTransaction(let errorLocalizedString):
            hasher.combine("unverifiedTransaction")
            hasher.combine(errorLocalizedString)
        case .networkError:
            hasher.combine("networkError")
        case .userCancelled:
            hasher.combine("userCancelled")
        case .userCannotMakePayments:
            hasher.combine("userCannotMakePayments")
        case .pending:
            hasher.combine("pending")
        }
    }
}
