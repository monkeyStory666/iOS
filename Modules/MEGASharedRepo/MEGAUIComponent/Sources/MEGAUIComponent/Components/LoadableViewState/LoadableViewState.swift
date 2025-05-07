// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum LoadableViewState<Element: Equatable>: Equatable {
    case idle
    case loading
    case loaded(_ element: Element)
    case failed

    public var loadedValue: Element? {
        if case let .loaded(element) = self {
            return element
        } else {
            return nil
        }
    }

    public var isLoaded: Bool { loadedValue != nil }
}
