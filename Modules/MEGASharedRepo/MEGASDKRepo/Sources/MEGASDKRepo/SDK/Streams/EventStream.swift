// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

public final class EventStream: NSObject, MEGAGlobalDelegate {
    private let sdk: MEGASdk
    private let queueType: ListenerQueueType

    private var continuation: AsyncStream<MEGAEvent>.Continuation?

    public var events: AsyncStream<MEGAEvent> {
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
        queueType: ListenerQueueType = .globalBackground
    ) {
        self.sdk = sdk
        self.queueType = queueType
        super.init()
    }

    public func stop() {
        continuation?.finish()
    }

    public func onEvent(_ api: MEGASdk, event: MEGAEvent) {
        continuation?.yield(event)
    }
}
