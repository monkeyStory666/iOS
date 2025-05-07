// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MEGAStoreKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAStoreKit",
            targets: ["MEGAStoreKit"]
        ),
        .library(
            name: "MEGAStoreKitMocks",
            targets: ["MEGAStoreKitMocks"]
        ),
    ],
    dependencies: [
        .package(path: "../MEGAAccountManagement"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGASDKRepo"),
        .package(path: "../MEGATest"),
        .package(path: "../MEGASwift"),
        .package(path: "../../DataSource/MEGASDK")
    ],
    targets: [
        .target(
            name: "MEGAStoreKit",
            dependencies: [
                .product(name: "MEGAAccountManagement", package: "MEGAAccountManagement"),
                .product(name: "MEGAInfrastructure", package: "MEGAInfrastructure"),
                .product(name: "MEGASDKRepo", package: "MEGASDKRepo"),
                .product(name: "MEGASwift", package: "MEGASwift"),
                .product(name: "MEGASdk", package: "MEGASDK")
            ]
        ),
        .target(
            name: "MEGAStoreKitMocks",
            dependencies: [
                "MEGAStoreKit",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGAStoreKitTests",
            dependencies: [
                "MEGAStoreKit",
                "MEGAStoreKitMocks",
                .product(name: "MEGATest", package: "MEGATest"),
                .product(name: "MEGAAccountManagementMocks", package: "MEGAAccountManagement"),
                .product(name: "MEGASDKRepoMocks", package: "MEGASDKRepo"),
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGASdk", package: "MEGASDK")
            ]
        )
    ]
)
