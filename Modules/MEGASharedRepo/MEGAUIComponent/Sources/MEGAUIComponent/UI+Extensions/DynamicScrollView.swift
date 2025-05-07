// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat

    static let defaultValue: CGFloat = 40

    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value = nextValue()
    }
}

public struct DynamicScrollView<ContentView: View>: View {
    @ViewBuilder public var content: () -> ContentView

    @State private var contentHeight: CGFloat = 40

    public init(
        @ViewBuilder content: @escaping () -> ContentView
    ) {
        self.content = content
    }

    public var body: some View {
        Group {
            if #available(iOS 16.4, *) {
                scrollableContent
                    .scrollIndicators(.visible)
                    .scrollBounceBehavior(.basedOnSize)
            } else {
                scrollableContent
            }
        }
    }

    var scrollableContent: some View {
        ScrollView {
            content()
                .overlay(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: HeightPreferenceKey.self,
                            value: geo.size.height
                        )
                    }
                )
        }
        .frame(maxHeight: contentHeight)
        .onPreferenceChange(HeightPreferenceKey.self) { [$contentHeight] value in
            $contentHeight.wrappedValue = value
        }
    }
}

struct DynamicScrollableView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicScrollView {
            VStack {
                ForEach(1 ... 6, id: \.self) { _ in
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
