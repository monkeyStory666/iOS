// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MEGAUIComponent",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAUIComponent",
            targets: ["MEGAUIComponent"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", exact: "1.2.0"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main")
    ],
    targets: [
        .target(
            name: "MEGAUIComponent",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken"),
            ],
            resources: [.process("Assets")]
        )
    ]
)
