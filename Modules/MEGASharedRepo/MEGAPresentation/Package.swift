// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEGAPresentation",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAPresentation",
            targets: ["MEGAPresentation"]
        ),
        .library(
            name: "MEGAPresentationMocks",
            targets: ["MEGAPresentationMocks"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths.git",
            from: "0.14.0"
        ),
        .package(path: "../ImpressionKit"),
        .package(path: "../MEGAInfrastructure"),
        .package(path: "../MEGATest")
    ],
    targets: [
        .target(
            name: "MEGAPresentation",
            dependencies: [
                "MEGAInfrastructure",
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ImpressionKit", package: "ImpressionKit")
            ]
        ),
        .target(
            name: "MEGAPresentationMocks",
            dependencies: [
                "MEGAPresentation",
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
        .testTarget(
            name: "MEGAPresentationTests",
            dependencies: [
                "MEGAPresentation",
                "MEGAPresentationMocks",
                "MEGAInfrastructure",
                .product(name: "MEGAInfrastructureMocks", package: "MEGAInfrastructure"),
                .product(name: "MEGATest", package: "MEGATest")
            ]
        ),
    ]
)
