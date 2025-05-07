// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAAnalytics",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAAnalytics",
            targets: ["MEGAAnalytics"]),
        .library(
            name: "MEGAAnalyticsMock",
            targets: ["MEGAAnalyticsMock"])
    ],
    dependencies: [
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../MEGAInfrastructure"),
        .package(url: "https://code.developers.mega.co.nz/mobile/kmm/mobile-analytics-ios.git", branch: "main")
    ],
    targets: [
        .target(
            name: "MEGAAnalytics",
            dependencies: [
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGAAnalyticsiOS", package: "mobile-analytics-ios", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "MEGAAnalyticsMock",
            dependencies: ["MEGAAnalytics"]
        ),
        .testTarget(
            name: "MEGAAnalyticsTests",
            dependencies: [
                "MEGAAnalytics",
                "MEGAAnalyticsMock",
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure")
            ]
        ),
    ]
)
