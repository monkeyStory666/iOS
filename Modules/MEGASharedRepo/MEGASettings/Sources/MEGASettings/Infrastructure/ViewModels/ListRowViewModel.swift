// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation
import SwiftUI

public protocol ListRowViewModel: ObservableObject {
    associatedtype RowView: View

    var rowView: RowView { get }

    func onLoad() async
}

public extension ListRowViewModel {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }

    func onLoad() async {}
}
