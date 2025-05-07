// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGADebugLogger",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGADebugLogger",
            targets: ["MEGADebugLogger"]
        ),
        .library(
            name: "MEGADebugLoggerMocks",
            targets: ["MEGADebugLoggerMocks"]
        ),
    ],
    dependencies: [
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGAAnalytics"),
        .package(path: "../MEGALogger"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGAUIComponent"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGASharedRepoL10n"),
        .package(path: "../MEGAPreference"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.0.0"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(path: "../MEGATest"),
    ],
    targets: [
        .target(
            name: "MEGADebugLogger",
            dependencies: [
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGALogger", package: "MEGALogger"),
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGAPreference", package: "MEGAPreference"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken"),
            ],
            resources: [.process("Assets")]
        ),
        .target(
            name: "MEGADebugLoggerMocks",
            dependencies: [
                "MEGADebugLogger",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGADebugLoggerTests",
            dependencies: [
                "MEGADebugLogger",
                "MEGADebugLoggerMocks",
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGAAnalyticsMock", package: "MEGAAnalytics"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGALoggerMocks", package: "MEGALogger"),
                .product(name: "MEGAPresentationMocks", package: "MEGAPresentation"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGATest", package: "MEGATest"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent")
            ]
        ),
    ]
)
