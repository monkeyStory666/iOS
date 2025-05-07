// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASwift

public protocol AppEnvironmentUseCaseProtocol: Sendable {
    var configuration: AppConfigurationEntity { get }

    func config(_ configuration: AppConfigurationEntity)
}

public final class AppEnvironmentUseCase: AppEnvironmentUseCaseProtocol {
    public static let shared = AppEnvironmentUseCase()

    private let _configuration: Atomic<AppConfigurationEntity>

    public var configuration: AppConfigurationEntity { _configuration.wrappedValue }

    private init(configuration: AppConfigurationEntity = .production) {
        _configuration = .init(wrappedValue: configuration)
    }

    public func config(_ configuration: AppConfigurationEntity) {
        _configuration.mutate { $0 = configuration }
    }
}
