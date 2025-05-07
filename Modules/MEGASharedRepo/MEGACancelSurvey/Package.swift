// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGACancelSurvey",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MEGACancelSurvey",
            targets: ["MEGACancelSurvey"]
        ),
        .library(
            name: "MEGACancelSurveyMocks",
            targets: ["MEGACancelSurveyMocks"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGASharedRepoL10n"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGAUIComponent"),
        .package(path: "../MEGAAnalytics")
    ],
    targets: [
        .target(
            name: "MEGACancelSurvey",
            dependencies: [
                "MEGADesignToken",
                .product(name: "MEGASdk", package: "MEGASDK"),
                "MEGASDKRepo",
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                "MEGAInfrastructure",
                "MEGAPresentation",
                "MEGASharedRepoL10n",
                "MEGASwift",
                "MEGAUIComponent"
            ]
        ),
        .target(
            name: "MEGACancelSurveyMocks",
            dependencies: [
                "MEGACancelSurvey",
                "MEGATest"
            ]
        ),
        .testTarget(
            name: "MEGACancelSurveyTests",
            dependencies: [
                "MEGACancelSurvey",
                "MEGACancelSurveyMocks",
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                .product(name: "MEGAAnalyticsMock", package: "MEGAAnalytics"),
                .product(name: "MEGASdk", package: "MEGASDK"),
                "MEGASDKRepo",
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
                "MEGAInfrastructure",
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                "MEGASwift",
                "MEGATest",
                "MEGAUIComponent"
            ]
        )
    ]
)
