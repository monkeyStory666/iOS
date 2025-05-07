// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAWhatsNew",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAWhatsNew",
            targets: ["MEGAWhatsNew"]
        ),
        .library(
            name: "MEGAWhatsNewMocks",
            targets: ["MEGAWhatsNewMocks"]
        )
    ],
    dependencies: [
        .package(path: "../MEGAAnalytics"),
        .package(url: "https://github.com/meganz/MEGADesignToken.git", branch: "main"),
        .package(path: "../MEGAAccountManagement"),
        .package(path: "../MEGAUIComponent"),
        .package(path: "../MEGAPresentation"),
        .package(path: "../MEGASwift"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGATest")
    ],
    targets: [
        .target(
            name: "MEGAWhatsNew",
            dependencies: [
                .product(name: "MEGAAnalytics", package: "MEGAAnalytics"),
                "MEGADesignToken",
                "MEGAAccountManagement",
                "MEGAUIComponent",
                "MEGAPresentation",
                "MEGASwift",
                "MEGAInfrastructure"
            ]
        ),
        .target(
            name: "MEGAWhatsNewMocks",
            dependencies: [
                "MEGAWhatsNew"
            ]
        ),
        .testTarget(
            name: "MEGAWhatsNewTests",
            dependencies: [
                "MEGAWhatsNew",
                "MEGAAccountManagement",
                .product(name: "MEGAAccountManagementMocks", package: "MEGAAccountManagement"),
                "MEGAInfrastructure",
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
    ]
)
