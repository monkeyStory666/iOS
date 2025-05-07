// Copyright © 2023 MEGA Limited. All rights reserved.

import StoreKit

extension StoreError {
    init?(_ storeKitError: StoreKitError?) {
        guard let storeKitError else { return nil }

        switch storeKitError {
        case .userCancelled:
            self = .userCancelled
        case .unknown:
            self = .generic(storeKitError.localizedDescription)
        case .networkError:
            self = .networkError
        case .systemError:
            self = .system("StoreKitError.systemError")
        case .notAvailableInStorefront:
            self = .notAvailableInRegion
        case .notEntitled:
            self = .invalid("StoreKitError.notEntitled")
        @unknown default:
            self = .generic(storeKitError.localizedDescription)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    init?(_ skError: SKError?) {
        guard let skError else { return nil }

        switch skError.code {
        case .clientInvalid:
            self = .invalid("SKError.clientInvalid")
        case .cloudServiceNetworkConnectionFailed:
            self = .networkError
        case .cloudServicePermissionDenied:
            self = .invalid("SKError.cloudServicePermissionDenied")
        case .cloudServiceRevoked:
            self = .invalid("SKError.cloudServiceRevoked")
        case .ineligibleForOffer:
            self = .offerInvalid("SKError.ineligibleForOffer")
        case .invalidOfferIdentifier:
            self = .offerInvalid("SKError.invalidOfferIdentifier")
        case .invalidOfferPrice:
            self = .offerInvalid("SKError.invalidOfferPrice")
        case .invalidSignature:
            self = .invalid("SKError.invalidSignature")
        case .missingOfferParams:
            self = .offerInvalid("SKError.missingOfferParams")
        case .overlayCancelled:
            self = .generic(skError.localizedDescription)
        case .overlayInvalidConfiguration:
            self = .generic(skError.localizedDescription)
        case .overlayPresentedInBackgroundScene:
            self = .generic(skError.localizedDescription)
        case .overlayTimeout:
            self = .generic(skError.localizedDescription)
        case .paymentCancelled:
            self = .userCancelled
        case .paymentInvalid:
            self = .generic(skError.localizedDescription)
        case .paymentNotAllowed:
            self = .userCannotMakePayments
        case .privacyAcknowledgementRequired:
            self = .invalid("SKError.privacyAcknowledgementRequired")
        case .storeProductNotAvailable:
            self = .notAvailableInRegion
        case .unauthorizedRequestData:
            self = .invalid("SKError.unauthorizedRequestData")
        case .unknown:
            self = .generic(skError.localizedDescription)
        case .unsupportedPlatform:
            self = .system("SKError.unsupportedPlatform")
        @unknown default:
            self = .generic(skError.localizedDescription)
        }
    }

    typealias ProductPurchaseError = Product.PurchaseError

    init?(_ productPurchaseError: ProductPurchaseError?) {
        guard let productPurchaseError else { return nil }

        switch productPurchaseError {
        case .invalidQuantity:
            self = .invalid("Product.PurchaseError.invalidQuantity")
        case .productUnavailable:
            self = .notAvailableInRegion
        case .purchaseNotAllowed:
            self = .userCannotMakePayments
        case .ineligibleForOffer:
            self = .offerInvalid("Product.PurchaseError.ineligibleForOffer")
        case .invalidOfferIdentifier:
            self = .offerInvalid("Product.PurchaseError.invalidOfferIdentifier")
        case .invalidOfferPrice:
            self = .offerInvalid("Product.PurchaseError.invalidOfferPrice")
        case .invalidOfferSignature:
            self = .offerInvalid("Product.PurchaseError.invalidOfferSignature")
        case .missingOfferParameters:
            self = .offerInvalid("Product.PurchaseError.missingOfferParameters")
        @unknown default:
            self = .generic(productPurchaseError.localizedDescription)
        }
    }

    typealias VerificationError = VerificationResult<Transaction>.VerificationError

    init?(_ verificationError: VerificationError?) {
        guard let verificationError else { return nil }

        self = .unverifiedTransaction(verificationError.localizedDescription)
    }

    init?(error: Error) {
        if let error = error as? StoreError {
            self = error
        } else if let error = StoreError(error as? StoreKitError) {
            self = error
        } else if let error = StoreError(error as? SKError) {
            self = error
        } else if let error = StoreError(error as? ProductPurchaseError) {
            self = error
        } else if let error = StoreError(error as? VerificationError) {
            self = error
        } else {
            return nil
        }
    }
}
