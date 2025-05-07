// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SharedReleaseScript",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SharedReleaseScript",
            targets: ["SharedReleaseScript"]
        ),
    ],
    targets: [
        .target(name: "SharedReleaseScript")
    ]
)
