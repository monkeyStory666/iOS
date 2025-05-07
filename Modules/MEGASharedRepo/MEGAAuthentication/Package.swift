// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("ExistentialAny")
]

let package = Package(
    name: "MEGAAuthentication",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAAuthentication",
            targets: ["MEGAAuthentication"]
        ),
        .library(
            name: "MEGAAuthenticationOrchestration",
            targets: ["MEGAAuthenticationOrchestration"]
        ),
        .library(
            name: "MEGAAuthenticationMocks",
            targets: ["MEGAAuthenticationMocks"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths.git",
            from: "0.14.0"
        ),
        .package(path: "../../DataSource/MEGASDK"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGAUIComponent"),
        .package(path: "../MEGAConnectivity"),
        .package(path: "../MEGADeeplinkHandling"),
        .package(path: "../MEGAAnalytics"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGASharedRepoL10n")
    ],
    targets: [
        .target(
            name: "MEGAAuthentication",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGAConnectivity", package: "MEGAConnectivity"),
                .product(name: "MEGADeeplinkHandling", package: "MEGADeeplinkHandling"),
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n")
            ],
            resources: [.process("Assets")],
            swiftSettings: settings
        ),
        .target(
            name: "MEGAAuthenticationOrchestration",
            dependencies: [
                "MEGAAuthentication"
            ],
            swiftSettings: settings
        ),
        .target(
            name: "MEGAAuthenticationMocks",
            dependencies: [
                "MEGAAuthentication",
                .product(name: "MEGATest", package: "MEGATest")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MEGAAuthenticationTests",
            dependencies: [
                "MEGAAuthentication",
                "MEGAAuthenticationMocks",
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGATest", package: "MEGATest"),
                .product(name: "MEGAConnectivityMocks", package: "MEGAConnectivity"),
                .product(name: "MEGAPresentationMocks", package: "MEGAPresentation"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGAAnalyticsMock", package: "MEGAAnalytics")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "MEGAAuthenticationOrchestrationTests",
            dependencies: [
                "MEGAAuthenticationOrchestration",
                "MEGAAuthenticationMocks",
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGATest", package: "MEGATest")
            ],
            swiftSettings: settings
        ),
    ]
)
