// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

public enum SDKEnvironment: String, Sendable {
    case production = "Production"
    case staging = "Staging"

    public var url: String {
        switch self {
        case .production:
            return "https://g.api.mega.co.nz/"
        case .staging:
            return "https://staging.api.mega.co.nz/"
        }
    }
}

extension SDKEnvironment: CaseIterable {}
extension SDKEnvironment: Codable {}
