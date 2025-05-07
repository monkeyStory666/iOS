// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

public protocol ChangeSDKEnvironmentRepositoryProtocol {
    func setSDKEnvironment(_ environment: SDKEnvironment)
}

public struct ChangeSDKEnvironmentRepository: ChangeSDKEnvironmentRepositoryProtocol {
    private let sdk: MEGASdk

    public init(sdk: MEGASdk) {
        self.sdk = sdk
    }

    public func setSDKEnvironment(_ environment: SDKEnvironment) {
        sdk.changeApiUrl(environment.url, disablepkp: false)
    }
}
