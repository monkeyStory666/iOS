// swift-tools-version: 6.0

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("ExistentialAny")
]

let package = Package(
    name: "MEGASwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGASwift",
            targets: ["MEGASwift"]
        )
    ],
    targets: [
        .target(
            name: "MEGASwift",
            dependencies: [],
            swiftSettings: settings),
        .testTarget(
            name: "MEGASwiftTests",
            dependencies: ["MEGASwift"],
            swiftSettings: settings)
    ],
    swiftLanguageModes: [.v6]
)
