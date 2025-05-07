// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAStoreKit
import MEGASdk
import MEGASDKRepoMocks
import MEGATest
import XCTest

final class PurchaseRepositoryTests: XCTestCase {
    func testSubmitPurchase_withReceipt_shouldSubmitItunesReceiptInSdk() async {
        let mockSdk = MockPurchaseSdk()
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        try? await sut.submitPurchase(with: expectedReceipt)

        let submitPurchaseCalls = await mockSdk.submitPurchaseCalls
        XCTAssertEqual(submitPurchaseCalls.count, 1)
        XCTAssertEqual(
            submitPurchaseCalls.first?.gateway,
            .itunes
        )
        XCTAssertEqual(
            submitPurchaseCalls.first?.receipt,
            expectedReceipt
        )
    }

    func testSubmitPurchase_whenApiOK_shouldNotThrow() async throws {
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: .apiOk
            )
        )
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        try await sut.submitPurchase(with: expectedReceipt)
    }

    func testSubmitPurchase_whenApiEExpired_shouldThrowExpiredError() async throws {
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: MockSdkError(type: .apiEExpired)
            )
        )
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        do {
            try await sut.submitPurchase(with: expectedReceipt)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertEqual(error as? PurchaseError, PurchaseError.expiredOrInvalidReceipt)
        }
    }

    func testSubmitPurchase_whenApiEExist_shouldThrowAlreadyExist() async throws {
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: MockSdkError(type: .apiEExist)
            )
        )
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        do {
            try await sut.submitPurchase(with: expectedReceipt)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertEqual(error as? PurchaseError, PurchaseError.alreadyExist)
        }
    }

    func testSubmitPurchase_whenApiEAccess_shouldThrowReceiptUsed() async throws {
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: MockSdkError(type: .apiEAccess)
            )
        )
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        do {
            try await sut.submitPurchase(with: expectedReceipt)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertEqual(error as? PurchaseError, PurchaseError.receiptUsed)
        }
    }

    func testSubmitPurchase_shouldThrow_onOtherError() async {
        let expectedError = MockSdkError(type: .apiEFailed)
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: expectedError
            )
        )
        let expectedReceipt = String.random(withPrefix: "receipt")
        let sut = makeSUT(sdk: mockSdk)

        do {
            try await sut.submitPurchase(with: expectedReceipt)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertEqual(
                error as? PurchaseError,
                PurchaseError.generic(expectedError.localizedDescription)
            )
        }
    }

    func testSubmitPurchase_multipleTimes_inDifferentTasks_shouldOnlyCalledOnce_withSameResult() async {
        let mockSdk = MockPurchaseSdk(
            submitPurchaseCompletion: requestDelegateFinished(
                error: {
                    let errors: [MEGAError] = [
                        MockSdkError(type: .apiEAccess),
                        MockSdkError(type: .apiEAgain),
                        MockSdkError(type: .apiECircular)
                    ]

                    return errors.randomElement()!
                }()
            )
        )
        let sut = makeSUT(sdk: mockSdk)
        let receipt = String.random(withPrefix: "receipt")

        async let expectedError1: MEGAError? = Task {
            do {
                try await sut.submitPurchase(with: receipt)
                XCTFail("Expected to throw error")
            } catch { return error as? MEGAError }
            return nil
        }.value

        async let expectedError2: MEGAError? = Task {
            do {
                try await sut.submitPurchase(with: receipt)
                XCTFail("Expected to throw error")
            } catch { return error as? MEGAError }
            return nil
        }.value

        let expectedResult1 = await expectedError1
        let expectedResult2 = await expectedError2
        XCTAssertEqual(expectedResult1, expectedResult2)

        let submitPurchaseCalls = await mockSdk.submitPurchaseCalls
        XCTAssertEqual(submitPurchaseCalls.count, 1)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockPurchaseSdk = MockPurchaseSdk()
    ) -> PurchaseRepository {
        PurchaseRepository(sdk: sdk)
    }
}

private final class MockPurchaseSdk: MEGASdk, @unchecked Sendable  {
    var submitPurchaseCompletion: RequestDelegateStub

    @MainActor var submitPurchaseCalls = [(gateway: MEGAPaymentMethod, receipt: String)]()

    init(
        submitPurchaseCompletion: @escaping RequestDelegateStub = requestDelegateFinished()
    ) {
        self.submitPurchaseCompletion = submitPurchaseCompletion
        super.init()
    }

    override func submitPurchase(
        _ gateway: MEGAPaymentMethod,
        receipt: String,
        delegate: MEGARequestDelegate
    ) {
        Task {
            await MainActor.run {
                submitPurchaseCalls.append((gateway, receipt))
            }
            submitPurchaseCompletion(delegate, self)
        }
    }
}
