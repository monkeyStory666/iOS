// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGASDKRepo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MEGASDKRepo",
            targets: ["MEGASDKRepo"]
        ),
        .library(
            name: "MEGASDKRepoMocks",
            targets: ["MEGASDKRepoMocks"]
        )
    ],
    dependencies: [
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGASwift")
    ],
    targets: [
        .target(
            name: "MEGASDKRepo",
            dependencies: [
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASwift", package: "MEGASwift")
            ]
        ),
        .target(
            name: "MEGASDKRepoMocks",
            dependencies: [
                "MEGASDKRepo",
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGASDKRepoTests",
            dependencies: [
                "MEGASDKRepo",
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGATest", package: "MEGATest"),
            ]
        ),
    ]
)
