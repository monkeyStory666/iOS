//
//  AccountSubscriptionFeatureEntity+Dummy.swift
//  
//
//  Created by Aleksa Simic on 8/5/24.
//

import Foundation
import MEGAAccountManagement

public extension AccountSubscriptionEntity {
    static func sample(
        key: String = "proI",
        type: AccountPlanTypeEntity = .free,
        features: [String] = [],
        paymentMethod: PaymentMethodEntity = .webClient,
        renewTime: TimeInterval = 0,
        isTrial: Bool = false
    ) -> Self {
        AccountSubscriptionEntity(
            key: key,
            type: type,
            features: features,
            paymentMethod: paymentMethod,
            renewTime: renewTime,
            isTrial: isTrial
        )
    }
}
