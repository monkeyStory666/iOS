// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGALogger",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGALogger",
            targets: ["MEGALogger"]
        ),
        .library(
            name: "MEGALoggerMocks",
            targets: ["MEGALoggerMocks"]
        )
    ],
    dependencies: [
        .package(path: "../../DataSource/MEGASDK"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.0.0"),
        .package(path: "../MEGATest"),
    ],
    targets: [
        .target(
            name: "MEGALogger",
            dependencies: [
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]
        ),
        .target(
            name: "MEGALoggerMocks",
            dependencies: [
                "MEGALogger",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGALoggerTests",
            dependencies: [
                "MEGALogger",
                "MEGALoggerMocks",
                .product(name: "MEGASdk", package: "MEGASDK")
            ]
        ),
    ]
)
