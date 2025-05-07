// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MEGADeeplinkHandling",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MEGADeeplinkHandling",
            targets: ["MEGADeeplinkHandling"]),
    ],
    targets: [
        .target(
            name: "MEGADeeplinkHandling"),
        .testTarget(
            name: "MEGADeeplinkHandlingTests",
            dependencies: ["MEGADeeplinkHandling"]),
    ],
    swiftLanguageModes: [.v6]
)
