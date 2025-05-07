import MEGADesignToken
import SwiftUI

public struct MEGATopBar<Header: View>: View {
    public struct TabItem {
        let text: String
        let content: AnyView

        public init(
            title: String,
            content: AnyView
        ) {
            self.text = title
            self.content = content
        }
    }

    private var scrollViewDelegate = ScrollViewDelegate()

    private let fillScreenWidth: Bool
    private let header: Header
    private let tabItems: [TabItem]

    private let scrollViewCoordinateSpace = "scrollViewCoordinateSpace"

    public init(
        tabs: [TabItem],
        fillScreenWidth: Bool = false,
        @ViewBuilder header: () -> Header
    ) {
        self.tabItems = tabs
        self.fillScreenWidth = fillScreenWidth
        self.header = header()
    }

    @State private var scrollOffsetVertical: CGFloat = 0
    @State private var headerViewHeight: CGFloat = 0
    @State private var selectedTab = 0
    @State private var tabWidths = [Int: CGFloat]()
    @State private var screenWidth: CGFloat?
    @State private var tabsHorizontalScrollProxy: ScrollViewProxy?

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                content
                stickyHeader
            }
            .onAppear {
                screenWidth = proxy.size.width
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: .zero) {
                header
                    .sizeReader { headerViewHeight = $0.height }

                tabsContent
            }
            .background(
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named(scrollViewCoordinateSpace)).minY
                    Color.clear.preference(key: ViewOffsetKey.self, value: CGPoint(x: 0, y: offset))
                }
            )
        }
        .coordinateSpace(name: scrollViewCoordinateSpace)
        .onPreferenceChange(ViewOffsetKey.self) { [$scrollOffsetVertical] value in
            $scrollOffsetVertical.wrappedValue = value.y
        }
    }

    private var stickyHeader: some View {
        tabsView
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .opacity(scrollOffsetVertical < -headerViewHeight ? 1 : 0)
    }


    private var tabsContent: some View {
        VStack(spacing: .zero) {
            tabsView
            tabsHorizontalScrollContent
        }
    }

    private var tabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .crossAlignment, spacing: .zero) {
                tabs
                selectionIndicator
            }
        }
        .frame(height: 48)
        .background(systemBackgroundColor)
    }

    private var tabs: some View {
        HStack(spacing: .zero) {
            ForEach(Array(tabItems.enumerated()), id: \.element.text) { tabIndex, tab in
                Button(action: {
                    withAnimation {
                        tabsHorizontalScrollProxy?.scrollTo(tabIndex)
                    }
                    selectedTab = tabIndex
                }) {
                    Text(tab.text)
                        .font(selectedTab == tabIndex ? .callout.bold() : .callout)
                        .foregroundColor(TokenColors.Text.primary.swiftUI)
                        .padding(.bottom, 8)
                        .padding(.top, 2)
                        .padding(.horizontal, 4)
                        .if(tabIndex == self.selectedTab) {
                            $0.alignmentGuide(.crossAlignment) { d in
                                d[HorizontalAlignment.center]
                            }
                        }
                        .if(fillScreenWidth) {
                            $0.frame(width: (screenWidth ?? 0)/CGFloat(tabItems.count))
                        }
                }
                .sizeReader { tabWidths[tabIndex] = $0.width }
            }
        }
    }

    private var selectionIndicator: some View {
        Rectangle()
            .fill(TokenColors.Components.interactive.swiftUI)
            .frame(width: tabWidths[selectedTab], height: 3)
            .alignmentGuide(.crossAlignment) { d in
                d[HorizontalAlignment.center]
            }
            .animation(.easeInOut, value: selectedTab)
    }

    private var tabsHorizontalScrollContent: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: .zero) {
                    ForEach(Array(tabItems.enumerated()), id: \.element.text) { index, item in
                        item.content
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .top
                            )
                            .frame(width: screenWidth)
                            .id(index)
                    }
                }
            }
            .onAppear {
                tabsHorizontalScrollProxy = proxy
            }
            .introspect(.scrollView, on: .iOS(.v15, .v16, .v17)) { scrollView in
                scrollView.isPagingEnabled = true
                scrollView.delegate = scrollViewDelegate
                scrollViewDelegate.onPageChange = { page in
                    withAnimation {
                        self.selectedTab = page
                    }
                }
            }
        }
    }

    var systemBackgroundColor: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static let defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.x += nextValue().x
        value.y += nextValue().y
    }
}

private class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var onPageChange: ((Int) -> Void)?

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = Int(fractionalPage)
        onPageChange?(page)
    }
}

private extension View {
    func sizeReader(_ block: @escaping (CGSize) -> Void) -> some View {
        overlay(
            GeometryReader { geometry -> Color in
                DispatchQueue.main.async {
                    block(geometry.size)
                }
                return Color.clear
            }
        )
    }
}

private extension HorizontalAlignment {
    private enum CrossAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }

    static let crossAlignment = HorizontalAlignment(CrossAlignment.self)
}

#Preview {
    MEGATopBar(tabs: [
        .init(
            title: "Google",
            content: AnyView(
                Text(String.loremIpsum(20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
            )
        ),
        .init(
            title: "Web client",
            content: AnyView(
                Text(String.loremIpsum(20))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
            )
        )
    ], header: {
        VStack(spacing: .zero) {
            Text("If you used Google Play to purchase a MEGA VPN subscription, you must cancel your subscription through the Google Play Store.")
            Text("If you’ve purchased a MEGA VPN subscription through the MEGA website, you must cancel your subscription through the MEGA website. ")
        }
    })
}
