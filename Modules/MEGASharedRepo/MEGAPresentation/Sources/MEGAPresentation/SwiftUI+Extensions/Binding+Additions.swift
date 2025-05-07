// Copyright © 2023 MEGA Limited. All rights reserved.

import CasePaths
import SwiftUI

public extension Binding {
    init?(unwrap binding: Binding<Value?>) {
        guard let wrappedValue = binding.wrappedValue
        else { return nil }

        self.init(
            get: { wrappedValue },
            set: { newValue in
                DispatchQueue.main.async {
                    binding.wrappedValue = newValue
                }
            }
        )
    }

    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    DispatchQueue.main.async {
                        self.wrappedValue = nil
                    }
                }
            }
        )
    }

    func isPresent<Enum>(
        _ casePath: CasePath<Enum, some Any>
    ) -> Binding<Bool> where Value == Enum? {
        .init(
            get: {
                if let wrappedValue = self.wrappedValue,
                   casePath.extract(from: wrappedValue) != nil
                {
                    true
                } else {
                    false
                }
            },
            set: { isPresented in
                if !isPresented {
                    DispatchQueue.main.async {
                        self.wrappedValue = nil
                    }
                }
            }
        )
    }

    func `case`<Enum, Case>(
        _ casePath: CasePath<Enum, Case>
    ) -> Binding<Case?> where Value == Enum? {
        Binding<Case?>(
            get: {
                guard
                    let wrappedValue = self.wrappedValue,
                    let `case` = casePath.extract(from: wrappedValue)
                else { return nil }
                return `case`
            },
            set: { `case` in
                DispatchQueue.main.async {
                    if let `case` {
                        self.wrappedValue = casePath.embed(`case`)
                    } else {
                        self.wrappedValue = nil
                    }
                }
            }
        )
    }
}
