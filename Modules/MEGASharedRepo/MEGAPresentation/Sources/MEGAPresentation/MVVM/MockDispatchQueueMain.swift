// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public final class MockDispatchQueueMain: DispatchQueueType {
    public func async(execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
