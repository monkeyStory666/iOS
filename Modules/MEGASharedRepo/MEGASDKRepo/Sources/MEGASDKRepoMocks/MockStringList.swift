// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

public class MockStringList: MEGAStringList {
    private let list: [String]

    public init(list: [String]) {
        self.list = list
    }

    public override var size: Int {
        list.count
    }

    public override func string(at index: Int) -> String? {
        list[index]
    }
}
