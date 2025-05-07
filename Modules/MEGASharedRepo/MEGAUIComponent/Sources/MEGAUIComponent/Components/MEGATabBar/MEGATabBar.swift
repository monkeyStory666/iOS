// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGADesignToken
import SwiftUI

public struct MEGATabBarItemEntity: Equatable {
    public var title: String
    public var activeIcon: Image
    public var inactiveIcon: Image
    public var newUpdateIndicator: Bool

    public init(
        title: String,
        activeIcon: Image,
        inactiveIcon: Image,
        newUpdateIndicator: Bool
    ) {
        self.title = title
        self.activeIcon = activeIcon
        self.inactiveIcon = inactiveIcon
        self.newUpdateIndicator = newUpdateIndicator
    }
}

public struct MEGATabBar: View {
    public var tabBarItems: [MEGATabBarItemEntity]

    @Binding public var activeTabIndex: Int

    public init(
        tabBarItems: [MEGATabBarItemEntity],
        activeTabIndex: Binding<Int>
    ) {
        self.tabBarItems = tabBarItems
        self._activeTabIndex = activeTabIndex
    }

    public var body: some View {
        if activeTabIndex >= 0, activeTabIndex < tabBarItems.count {
            HStack {
                ForEach(Array(zip(tabBarItems.indices, tabBarItems)), id: \.0) { (index, item) in
                    Button {
                        activeTabIndex = index
                    } label: {
                        TabBarItemView(isActive: activeTabIndex == index, item: item)
                    }
                }
            }
            .frame(height: 40, alignment: .top)
            .padding(.vertical, TokenSpacing._3)
            .border(
                width: 0.33,
                edges: [.top],
                color: TokenColors.Border.strong.swiftUI
            )
            .transition(.move(edge: .bottom))
            .ignoresSafeArea(.all, edges: .bottom)
        } else {
            EmptyView()
        }
    }
}

struct TabBarItemView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    public var isActive: Bool
    public var item: MEGATabBarItemEntity

    public var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                VStack(spacing: TokenSpacing._2) {
                    ZStack {
                        Group {
                            if isActive {
                                TabBarItemIcon(image: item.activeIcon)
                            } else {
                                TabBarItemIcon(image: item.inactiveIcon)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        if item.newUpdateIndicator {
                            Circle()
                                .foregroundStyle(TokenColors.Components.interactive.swiftUI)
                                .frame(width: 6, height: 6)
                                .frame(maxWidth: 40, maxHeight: 22, alignment: .topTrailing)
                        }
                    }
                    TabBarItemLabel(text: item.title)
                }
            } else if horizontalSizeClass == .regular {
                HStack(alignment: .center, spacing: TokenSpacing._3) {
                    if isActive {
                        TabBarItemIcon(image: item.activeIcon)
                    } else {
                        TabBarItemIcon(image: item.inactiveIcon)
                    }
                    TabBarItemLabel(text: item.title)
                    if item.newUpdateIndicator {
                        Circle()
                            .foregroundStyle(TokenColors.Components.interactive.swiftUI)
                            .frame(width: 6, height: 6)
                            .frame(maxHeight: 22, alignment: .topTrailing)
                    }
                }
            }
        }
        .foregroundStyle(
            isActive
                ? TokenColors.Button.brand.swiftUI
                : TokenColors.Icon.secondary.swiftUI
        )
        .frame(maxWidth: .infinity, maxHeight: 48, alignment: .center)
    }
}

struct TabBarItemIcon: View {
    var image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: 22,
                height: 22,
                alignment: .center
            )
    }
}

struct TabBarItemLabel: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10))
    }
}

struct MEGATabBar_Previews: PreviewProvider {
    static var previews: some View {
        MEGATabBarPreview()
    }
}

private struct MEGATabBarPreview: View {
    enum Tab: Int, CaseIterable {
        case tabOne = 1
        case tabTwo = 2
        case tabThree = 3
        case tabFour = 4
        case tabFive = 5

        func tabEntity(newUpdateIndicator: Bool = false) -> MEGATabBarItemEntity {
            MEGATabBarItemEntity(
                title: "Tab \(rawValue)",
                activeIcon: Image(systemName: "square.dashed.inset.filled"),
                inactiveIcon: Image(systemName: "square.dashed"),
                newUpdateIndicator: rawValue.isMultiple(of: 2)
            )
        }
    }

    @State var activeTabIndexTwo: Int = 0
    @State var activeTabIndexThree: Int = 0
    @State var activeTabIndexFour: Int = 0
    @State var activeTabIndexFive: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            Divider()
            Text("2 tabs")
            MEGATabBar(
                tabBarItems: Tab.allCases
                    .filter { $0.rawValue <= 2 }
                    .map { $0.tabEntity() },
                activeTabIndex: $activeTabIndexTwo
            )
            Divider()
            Text("3 tabs")
            MEGATabBar(
                tabBarItems: Tab.allCases
                    .filter { $0.rawValue <= 3 }
                    .map { $0.tabEntity() },
                activeTabIndex: $activeTabIndexThree
            )
            Divider()
            Text("4 tabs")
            MEGATabBar(
                tabBarItems: Tab.allCases
                    .filter { $0.rawValue <= 4 }
                    .map { $0.tabEntity() },
                activeTabIndex: $activeTabIndexFour
            )
            Divider()
            Text("5 tabs")
            MEGATabBar(
                tabBarItems: Tab.allCases
                    .filter { $0.rawValue <= 5 }
                    .map { $0.tabEntity() },
                activeTabIndex: $activeTabIndexFive
            )
            Divider()
        }
    }
}
