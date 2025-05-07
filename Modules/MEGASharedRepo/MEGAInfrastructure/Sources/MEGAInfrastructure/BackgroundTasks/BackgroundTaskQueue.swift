// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation

public enum BackgroundTaskQueue: Sendable {
    case main
    case global(qos: DispatchQoS.QoSClass)
}
