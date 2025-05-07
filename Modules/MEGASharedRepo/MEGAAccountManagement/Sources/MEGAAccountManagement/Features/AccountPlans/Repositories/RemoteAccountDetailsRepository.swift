// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAInfrastructure
import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct RemoteAccountDetailsRepository: RemoteDataRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func fetch() async throws -> AccountDetailsEntity {
        try await withAsyncThrowingValue { completion in
            sdk.getAccountDetails(with: RequestDelegate { result in
                switch result {
                case .success(let request):
                    if let accountDetails = request.megaAccountDetails {
                        completion(.success(.init(
                            plans: accountDetails.plans,
                            features: accountDetails.features,
                            subscriptions: accountDetails.accountSubscriptionFeatures
                        )))
                    } else {
                        completion(.failure(RemoteDataRepositoryErrorEntity.dataNotFound))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
}

extension MEGAAccountDetails {
    var plans: [AccountPlanEntity] {
        .init(
            numberOfItems: numberOfPlans,
            itemAtIndex: plan(at:),
            mapFunction: {
                AccountPlanEntity(
                    key: $0.subscriptionId,
                    type: $0.accountType.toPlanTypeEntity,
                    isProPlan: $0.isProPlan,
                    expiry: TimeInterval($0.expirationTime),
                    features: $0.features ?? [],
                    isTrial: $0.isTrial
                )
            }
        )
    }
}

extension MEGAAccountType {
    var toPlanTypeEntity: AccountPlanTypeEntity {
        switch self {
        case .free, .unknown: return .free
        case .proI: return .proI
        case .proII: return .proII
        case .proIII: return .proIII
        case .lite: return .lite
        case .starter: return .starter
        case .basic: return .basic
        case .essential: return .essential
        case .business: return .business
        case .proFlexi: return .proFlexi
        case .feature: return .feature
        @unknown default: return .free
        }
    }
}

extension MEGAAccountDetails {
    var features: [AccountFeatureEntity] {
        .init(
            numberOfItems: numActiveFeatures,
            itemAtIndex: activeFeature(at:),
            mapFunction: {
                .init(
                    featureId: $0.featureId,
                    expiry: TimeInterval($0.expiry)
                )
            }
        )
    }
}

extension MEGAAccountDetails {
    var accountSubscriptionFeatures: [AccountSubscriptionEntity] {
        .init(
            numberOfItems: numberOfSubscriptions,
            itemAtIndex: subscription(at:),
            mapFunction: {
                AccountSubscriptionEntity(
                    key: $0.subcriptionId ?? "",
                    type: $0.accountType.toPlanTypeEntity,
                    features: $0.features ?? [],
                    paymentMethod: $0.paymentMethodId.paymentMethodEntity,
                    renewTime: TimeInterval($0.renewTime),
                    isTrial: $0.isTrial
                )
            }
        )
    }
}

extension MEGAPaymentMethod {
    var paymentMethodEntity: PaymentMethodEntity {
        switch self {
        case .itunes: return .appleAppStore
        case .googleWallet: return .googlePlayStore
        default: return .webClient
        }
    }
}

