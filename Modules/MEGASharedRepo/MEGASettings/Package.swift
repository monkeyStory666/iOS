// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGASettings",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGASettings",
            targets: ["MEGASettings"]
        ),
    ],
    dependencies: [
        .package(path: "../MEGAAccountManagement"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGAUIComponent"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths.git",
            from: "0.14.0"
        ),
        .package(path: "../MEGAStoreKit"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGAAuthentication"),
        .package(path: "../MEGASharedRepoL10n"),
        .package(path: "../MEGAAnalytics"),
        .package(path: "../MEGADebugLogger"),
        .package(path: "../MEGAConnectivity"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGALogger"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../../DataSource/MEGASDK")
    ],
    targets: [
        .target(
            name: "MEGASettings",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "MEGAAccountManagement", package: "MEGAAccountManagement"),
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken"),
                .product(name: "MEGAStoreKit", package: "MEGAStoreKit"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGAAuthentication", package: "MEGAAuthentication"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGADebugLogger", package: "MEGADebugLogger"),
                .product(name: "MEGAConnectivity", package: "MEGAConnectivity"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGALogger", package: "MEGALogger"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
                .product(name: "MEGASdk", package: "MEGASDK")
            ],
            resources: [.process("Assets")]
        ),
        .testTarget(
            name: "MEGASettingsTests",
            dependencies: [
                "MEGASettings",
                .product(name: "MEGAAccountManagementMocks", package: "MEGAAccountManagement"),
                .product(name: "MEGAAnalyticsMock", package: "MEGAAnalytics"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGAPresentationMocks", package: "MEGAPresentation"),
                .product(name: "MEGAConnectivityMocks", package: "MEGAConnectivity"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
    ]
)
