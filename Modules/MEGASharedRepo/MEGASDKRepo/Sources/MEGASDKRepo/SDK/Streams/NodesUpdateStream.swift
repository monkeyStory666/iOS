// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGASdk

public protocol NodesUpdatesStreamProtocol {
    var updates: AsyncStream<MEGANodeList> { get }
}

public final class NodesUpdateStream: NSObject, MEGAGlobalDelegate, NodesUpdatesStreamProtocol {
    private let sdk: MEGASdk
    private let queueType: ListenerQueueType
    private var continuation: AsyncStream<MEGANodeList>.Continuation?

    public var updates: AsyncStream<MEGANodeList> {
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
    
    public func onNodesUpdate(_ api: MEGASdk, nodeList: MEGANodeList?) {
        guard let nodeList else { return }
        continuation?.yield(nodeList)
    }
}
