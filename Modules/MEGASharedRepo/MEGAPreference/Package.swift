// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MEGAPreference",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MEGAPreference",
            targets: ["MEGAPreference"]
        ),
    ],
    dependencies: [
        .package(path: "../MEGASwift"),
    ],
    targets: [
        .target(
            name: "MEGAPreference",
            dependencies: [
                .product(name: "MEGASwift", package: "MEGASwift"),
            ]),
        .testTarget(
            name: "MEGAPreferenceTests",
            dependencies: ["MEGAPreference"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
