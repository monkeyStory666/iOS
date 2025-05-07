import MEGASdk
import MEGASDKRepo
import MEGASwift

public struct AccountSuspensionUpdatesRepository: AccountSuspensionUpdatesRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public var accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity> {
        EventStream(sdk: sdk)
            .events
            .compactMap { event in
                AccountSuspensionType(from: event)?.toAccountSuspensionTypeEntity()
            }
            .eraseToAnyAsyncSequence()
    }
}
