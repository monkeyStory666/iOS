// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAConnectivity",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAConnectivity",
            targets: ["MEGAConnectivity"]
        ),
        .library(
            name: "MEGAConnectivityMocks",
            targets: ["MEGAConnectivityMocks"]
        )
    ],
    dependencies: [
        .package(path: "../MEGAUIComponent"),
        .package(path: "../MEGATest"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main")
    ],
    targets: [
        .target(
            name: "MEGAConnectivity",
            dependencies: [
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken")
            ]
        ),
        .target(
            name: "MEGAConnectivityMocks",
            dependencies: [
                "MEGAConnectivity",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGAConnectivityTests",
            dependencies: [
                "MEGAConnectivity",
                "MEGAConnectivityMocks",
                .product(name: "MEGATest", package: "MEGATest"),
            ]
        ),
        
    ]
)
