// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepareRelease",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(path: "../SharedReleaseScript")
    ],
    targets: [
        .executableTarget(
            name: "PrepareRelease",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SharedReleaseScript"
            ]
        ),
    ]
)
