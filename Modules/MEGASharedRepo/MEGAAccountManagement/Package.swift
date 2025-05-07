// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAAccountManagement",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAAccountManagement",
            targets: ["MEGAAccountManagement"]
        ),
        .library(
            name: "MEGAAccountManagementMocks",
            targets: ["MEGAAccountManagementMocks"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths.git",
            from: "0.14.0"
        ),
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGAUIComponent"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(path: "../MEGACancelSurvey"),
        .package(path: "../MEGAConnectivity"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGAAuthentication"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGASharedRepoL10n"),
        .package(path: "../MEGAAnalytics")
    ],
    targets: [
        .target(
            name: "MEGAAccountManagement",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGADesignToken", package: "MEGADesignToken"),
                .product(name: "MEGACancelSurvey", package: "MEGACancelSurvey"),
                .product(name: "MEGAConnectivity", package: "MEGAConnectivity"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGAAuthentication", package: "MEGAAuthentication"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics")
            ],
            resources: [.process("Assets")]
        ),
        .target(
            name: "MEGAAccountManagementMocks",
            dependencies: [
                "MEGAAccountManagement",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGAAccountManagementTests",
            dependencies: [
                "MEGAAccountManagement",
                "MEGAAccountManagementMocks",
                .product(name: "MEGACancelSurvey", package: "MEGACancelSurvey"),
                .product(name: "MEGACancelSurveyMocks", package: "MEGACancelSurvey"),
                .product(name: "MEGAAuthenticationMocks", package: "MEGAAuthentication"),
                .product(name: "MEGATest", package: "MEGATest"),
                .product(name: "MEGAPresentationMocks", package: "MEGAPresentation"),
                .product(name: "MEGAUIComponent", package: "MEGAUIComponent"),
                .product(name: "MEGAConnectivityMocks", package: "MEGAConnectivity"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGAAnalyticsMock", package: "MEGAAnalytics"),
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
            ]
        )
    ]
)
