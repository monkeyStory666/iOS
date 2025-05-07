// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {
    func border(width: CGFloat, edges: Edge.Set, color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: Edge.Set

    func path(in rect: CGRect) -> Path {
        var path = Path()

        if edges.contains(.top) {
            path.addPath(Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width)))
        }

        if edges.contains(.bottom) {
            path.addPath(Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width)))
        }

        if edges.contains(.leading) {
            path.addPath(Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height)))
        }

        if edges.contains(.trailing) {
            path.addPath(Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height)))
        }

        return path
    }
}
