// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("ExistentialAny")]

let package = Package(
    name: "MEGATest",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGATest",
            targets: ["MEGATest"]),
    ],
    dependencies: [
        .package(url: "https://code.developers.mega.co.nz/mobile/kmm/mobile-analytics-ios.git", branch: "main"),
        .package(path: "../MEGASwift"),
    ],
    targets: [
        .target(
            name: "MEGATest",
            dependencies: [
                .product(name: "MEGAAnalyticsiOS", package: "mobile-analytics-ios"),
                .product(name: "MEGASwift", package: "MEGASwift")
            ],
            swiftSettings: settings)
    ]
)
