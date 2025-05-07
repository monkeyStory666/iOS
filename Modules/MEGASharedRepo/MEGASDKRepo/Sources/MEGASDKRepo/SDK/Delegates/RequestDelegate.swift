// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

public typealias MEGARequestCompletion = (_ result: Result<MEGARequest, MEGAError>) async -> Void

public class RequestDelegate: NSObject, MEGARequestDelegate {
    let completion: MEGARequestCompletion
    private let successCodes: [MEGAErrorType]

    public init(
        successCodes: [MEGAErrorType] = [],
        completion: @escaping MEGARequestCompletion
    ) {
        self.successCodes = [.apiOk] + successCodes
        self.completion = completion
        super.init()
    }

    public func onRequestFinish(_ api: MEGASdk, request: MEGARequest, error: MEGAError) {
        if successCodes.contains(error.type) {
            Task {
                await self.completion(.success(request))
            }
        } else {
            Task {
                await self.completion(.failure(error))
            }
        }
    }
}
