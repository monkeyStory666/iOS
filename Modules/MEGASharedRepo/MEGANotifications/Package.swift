// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGANotifications",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MEGANotifications",
            targets: ["MEGANotifications"]),
        .library(
            name: "MEGANotificationsMocks",
            targets: ["MEGANotificationsMocks"]),
    ],
    dependencies: [
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGASharedRepoL10n"),
        .package(path: "../MEGATest"),
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGASDKRepo")
    ],
    targets: [
        .target(
            name: "MEGANotifications",
            dependencies: [
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo")
            ]
        ),
        .target(
            name: "MEGANotificationsMocks",
            dependencies: [
                "MEGANotifications",
                "MEGATest"
            ]
        ),
        .testTarget(
            name: "MEGANotificationsTests",
            dependencies: [
                "MEGANotifications",
                "MEGANotificationsMocks",
                .product(name: "MEGAPresentation", package: "MEGAPresentation"),
                .product(name: "MEGAPresentationMocks", package: "MEGAPresentation"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGASharedRepoL10n", package: "MEGASharedRepoL10n"),
                .product(name: "MEGATest", package: "MEGATest")
            ]),
    ]
)
