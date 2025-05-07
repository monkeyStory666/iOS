// Copyright © 2024 MEGA Limited. All rights reserved.

@testable import MEGAAuthentication
import MEGATest
import MEGASwift

public final class MockAccountSuspensionUpdatesUseCase:
    AccountSuspensionUpdatesUseCaseProtocol {
    public let accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity>
    
    public init(accountSuspensionUpdates: AnyAsyncSequence<AccountSuspensionTypeEntity> =
         AsyncStream<AccountSuspensionTypeEntity> { continuation in
        continuation.yield(.copyright)
        }
        .eraseToAnyAsyncSequence()
    ) {
        self.accountSuspensionUpdates = accountSuspensionUpdates
    }
}
