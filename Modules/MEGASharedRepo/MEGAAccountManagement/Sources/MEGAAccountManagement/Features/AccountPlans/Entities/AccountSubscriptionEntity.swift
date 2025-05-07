import Foundation

public struct AccountSubscriptionEntity: Equatable, Codable, Sendable {
    public let key: String
    public let type: AccountPlanTypeEntity
    public let features: [String]
    public let paymentMethod: PaymentMethodEntity
    public let renewTime: TimeInterval
    public let isTrial: Bool

    public init(
        key: String,
        type: AccountPlanTypeEntity,
        features: [String],
        paymentMethod: PaymentMethodEntity,
        renewTime: TimeInterval,
        isTrial: Bool
    ) {
        self.key = key
        self.type = type
        self.features = features
        self.paymentMethod = paymentMethod
        self.renewTime = renewTime
        self.isTrial = isTrial
    }
}
