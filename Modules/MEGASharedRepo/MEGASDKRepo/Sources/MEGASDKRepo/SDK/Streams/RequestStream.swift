import Foundation
import MEGASdk

public typealias RequestResultEntity = Result<MEGARequest, MEGAError>

public final class RequestStream: NSObject, MEGARequestDelegate {
    private let sdk: MEGASdk
    private let queueType: ListenerQueueType
    private let successCodes: [MEGAErrorType]

    private var continuation: AsyncStream<RequestResultEntity>.Continuation?

    public var requestEvents: AsyncStream<RequestResultEntity> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { _ in
                self.sdk.remove(self)
            }
            sdk.add(self, queueType: queueType)
        }
    }

    public init(
        sdk: MEGASdk,
        // Will respond to mainly actions that requires UI updates (e.g. logout)
        // so it need to has a high QoS (quality of service)
        queueType: ListenerQueueType = .globalUserInitiated,
        successCodes: [MEGAErrorType] = [.apiOk]
    ) {
        self.sdk = sdk
        self.queueType = queueType
        self.successCodes = successCodes
        super.init()
    }

    public func stop() {
        continuation?.finish()
    }

    public func onRequestFinish(_ api: MEGASdk, request: MEGARequest, error: MEGAError) {
        if successCodes.contains(error.type) {
            continuation?.yield(.success(request))
        } else {
            continuation?.yield(.failure(error))
        }
    }
}
