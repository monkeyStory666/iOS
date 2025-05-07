// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAInfrastructure
import MEGASdk
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct RemoteAccountDetailsRepositoryTests {
    // swiftlint:disable:next function_body_length
    @Test func fetch_whenMegaAccountDetailsExist_shouldReturnGetAccountDetailsFromSdk() async throws {
        func assert(
            accountDetails: MockAccountDetails,
            shouldReturnEntity expectedDetails: AccountDetailsEntity
        ) async throws {
            let sut = makeSUT(sdk: MockAccountPlanSdk(
                getAccountDetailsCompletion: requestDelegateFinished(
                    request: MockSdkRequest(
                        accountDetails: accountDetails
                    )
                )
            ))

            #expect(try await sut.fetch() == expectedDetails)
        }

        func assert(
            whenType type: MEGAAccountType,
            expectedPlanEntity: AccountPlanTypeEntity
        ) async throws {
            // Assert when single feature plan
            try await assert(
                accountDetails: MockAccountDetails(
                    type: type,
                    plans: [
                        MockAccountPlan(
                            subscriptionId: "subscriptionId",
                            accountType: type
                        )]
                    ,
                    features: [MockAccountFeature(featureId: "vpn", expiry: 0)],
                    subscriptions: [
                        MockSubscription(
                            subscriptionId: "subscriptionId",
                            accountType: .proII,
                            features: ["vpn", "pwm"],
                            paymentMethodId: .itunes,
                            renewTime: 123_456,
                            isTrial: true
                        ),
                        MockSubscription(
                            subscriptionId: "vpnStandalone",
                            accountType: .feature,
                            features: ["vpn"],
                            paymentMethodId: .googleWallet,
                            renewTime: 456,
                            isTrial: false
                        ),
                        MockSubscription(
                            subscriptionId: nil,
                            accountType: .feature,
                            features: [],
                            paymentMethodId: .stripe,
                            renewTime: 0,
                            isTrial: false
                        )
                    ]
                ),
                shouldReturnEntity: .sample(
                    plans: [
                        .sample(
                            subscriptionId: "subscriptionId",
                            type: expectedPlanEntity
                        )
                    ],
                    features: [AccountFeatureEntity(featureId: "vpn", expiry: 0)],
                    subscriptions: [
                        .sample(
                            key: "subscriptionId",
                            type: .proII,
                            features: ["vpn", "pwm"],
                            paymentMethod: .appleAppStore,
                            renewTime: 123_456,
                            isTrial: true
                        ),
                        .sample(
                            key: "vpnStandalone",
                            type: .feature,
                            features: ["vpn"],
                            paymentMethod: .googlePlayStore,
                            renewTime: 456,
                            isTrial: false
                        ),
                        .sample(
                            key: "",
                            type: .feature,
                            features: [],
                            paymentMethod: .webClient,
                            renewTime: 0,
                            isTrial: false
                        )
                    ]
                )
            )

            // Assert when empty feature plans
            try await assert(
                accountDetails: MockAccountDetails(
                    type: type,
                    plans: [MockAccountPlan(accountType: type)],
                    features: [],
                    subscriptions: []
                ),
                shouldReturnEntity: .sample(
                    plans: [.sample(type: expectedPlanEntity)],
                    features: [],
                    subscriptions: []
                )
            )

            // Assert when multiple feature plans
            try await assert(
                accountDetails: MockAccountDetails(
                    type: type,
                    plans: [MockAccountPlan(accountType: type)],
                    features: [
                        MockAccountFeature(featureId: "vpn", expiry: 321),
                        MockAccountFeature(featureId: "pwm", expiry: 123)
                    ],
                    subscriptions: []
                ),
                shouldReturnEntity: .sample(
                    plans: [.sample(type: expectedPlanEntity)],
                    features: [
                        AccountFeatureEntity(featureId: "vpn", expiry: 321),
                        AccountFeatureEntity(featureId: "pwm", expiry: 123)
                    ],
                    subscriptions: []
                )
            )
        }

        try await assert(whenType: .free, expectedPlanEntity: .free)
        try await assert(whenType: .proI, expectedPlanEntity: .proI)
        try await assert(whenType: .proII, expectedPlanEntity: .proII)
        try await assert(whenType: .proIII, expectedPlanEntity: .proIII)
        try await assert(whenType: .lite, expectedPlanEntity: .lite)
        try await assert(whenType: .business, expectedPlanEntity: .business)
        try await assert(whenType: .proFlexi, expectedPlanEntity: .proFlexi)
        try await assert(whenType: .starter, expectedPlanEntity: .starter)
        try await assert(whenType: .basic, expectedPlanEntity: .basic)
        try await assert(whenType: .essential, expectedPlanEntity: .essential)
    }

    @Test func fetch_whenAccountDetailsFromSdkIsEmpty_shouldThrowDataNotFoundError() async {
        let sut = makeSUT(sdk: MockAccountPlanSdk(
            getAccountDetailsCompletion: requestDelegateFinished(
                request: MockSdkRequest(accountDetails: nil)
            )
        ))

        await #expect(performing: {
            try await sut.fetch()
        }, throws: { error in
            isError(error, equalTo: RemoteDataRepositoryErrorEntity.dataNotFound)
        })
    }

    @Test func fetch_whenGetAccountDetailsFromSdkFailed_shouldThrowGenericError() async {
        let expectedError = MockSdkError.anyError
        let sut = makeSUT(sdk: MockAccountPlanSdk(
            getAccountDetailsCompletion: requestDelegateFinished(error: expectedError)
        ))

        await #expect(performing: {
            try await sut.fetch()
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockAccountPlanSdk = MockAccountPlanSdk()
    ) -> RemoteAccountDetailsRepository {
        RemoteAccountDetailsRepository(sdk: sdk)
    }
}

private final class MockAccountDetails: MEGAAccountDetails {
    var _type: MEGAAccountType
    var _features: [MEGAAccountFeature]
    var _plans: [MEGAAccountPlan]
    var _subscriptions: [MEGAAccountSubscription]

    init(
        type: MEGAAccountType,
        plans: [MEGAAccountPlan],
        features: [MEGAAccountFeature],
        subscriptions: [MEGAAccountSubscription]
    ) {
        _type = type
        _plans = plans
        _features = features
        _subscriptions = subscriptions
    }

    override var numActiveFeatures: NSInteger {
        _features.count
    }

    override func activeFeature(at index: Int) -> MEGAAccountFeature? {
        guard index < _features.count else { return nil }

        return _features[index]
    }

    override var numberOfPlans: NSInteger {
        _plans.count
    }

    override func plan(at index: Int) -> MEGAAccountPlan? {
        guard index < _plans.count else { return nil }

        return _plans[Int(index)]
    }

    override var numberOfSubscriptions: Int {
        _subscriptions.count
    }

    override func subscription(at index: Int) -> MEGAAccountSubscription? {
        guard index < _subscriptions.count else { return nil }

        return _subscriptions[index]
    }
}

private final class MockAccountFeature: MEGAAccountFeature {
    var _featureId: String?
    var _expiry: Int64

    init(
        featureId: String?,
        expiry: Int64
    ) {
        _featureId = featureId
        _expiry = expiry
    }

    override var featureId: String? {
        _featureId
    }

    override var expiry: Int64 {
        _expiry
    }
}

private final class MockAccountPlan: MEGAAccountPlan {
    var _subscriptionId: String?
    var _accountType: MEGAAccountType
    var _isProPlan: Bool
    var _expirationTime: Int64
    var _type: Int32
    var _features: [String]

    init(
        subscriptionId: String? = nil,
        accountType: MEGAAccountType,
        isProPlan: Bool = true,
        expirationTime: Int64 = 0,
        type: Int32 = 0,
        features: [String] = []
    ) {
        _subscriptionId = subscriptionId
        _accountType = accountType
        _isProPlan = isProPlan
        _expirationTime = expirationTime
        _type = type
        _features = features
    }

    override var subscriptionId: String? {
        _subscriptionId
    }

    override var accountType: MEGAAccountType {
        _accountType
    }

    override var isProPlan: Bool {
        _isProPlan
    }

    override var features: [String]? {
        _features
    }

    override var expirationTime: Int64 {
        _expirationTime
    }
}

private final class MockAccountPlanSdk: MEGASdk, @unchecked Sendable {
    var getAccountDetailsCompletion: RequestDelegateStub

    init(
        getAccountDetailsCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self.getAccountDetailsCompletion = getAccountDetailsCompletion
        super.init()
    }

    override func getAccountDetails(with delegate: MEGARequestDelegate) {
        getAccountDetailsCompletion(delegate, self)
    }
}

private final class MockSubscription: MEGAAccountSubscription {
    var _subscriptionId: String?
    var _accountType: MEGAAccountType
    var _features: [String]
    var _paymentMethodId: MEGAPaymentMethod
    var _renewTime: Int64
    var _isTrial: Bool

    init(
        subscriptionId: String?,
        accountType: MEGAAccountType,
        features: [String],
        paymentMethodId: MEGAPaymentMethod,
        renewTime: Int64,
        isTrial: Bool
    ) {
        _subscriptionId = subscriptionId
        _accountType = accountType
        _features = features
        _paymentMethodId = paymentMethodId
        _renewTime = renewTime
        _isTrial = isTrial
    }

    override var subcriptionId: String? {
        _subscriptionId
    }

    override var accountType: MEGAAccountType {
        _accountType
    }

    override var features: [String]? {
        _features
    }

    override var paymentMethodId: MEGAPaymentMethod {
        _paymentMethodId
    }

    override var renewTime: Int64 {
        _renewTime
    }

    override var isTrial: Bool {
        _isTrial
    }
}
