// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAInfrastructure",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAInfrastructure",
            targets: ["MEGAInfrastructure"]
        ),
        .library(
            name: "MEGAInfrastructureMocks",
            targets: ["MEGAInfrastructureMocks"]
        )
    ],
    dependencies: [
        .package(path: "../MEGALogger"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGASwift"),
        .package(path: "../../DataSource/MEGASDK"),
        .package(path: "../MEGASDKRepo"),
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "MEGAInfrastructure",
            dependencies: [
                .product(name: "DeviceKit", package: "devicekit"),
                .product(name: "MEGALogger", package: "MEGALogger"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGASdk", package: "MEGASDK"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
            ]
        ),
        .target(
            name: "MEGAInfrastructureMocks",
            dependencies: [
                "MEGAInfrastructure",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGAInfrastructureTests",
            dependencies: [
                "MEGAInfrastructure",
                "MEGAInfrastructureMocks",
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
            ]
        )
    ]
)
