// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MEGASharedRepoL10n",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MEGASharedRepoL10n",
            targets: ["MEGASharedRepoL10n"]
        )
    ],
    dependencies: [
        .package(path: "../MEGABuildTools"),
    ],
    targets: [
        .target(
            name: "MEGASharedRepoL10n",
            dependencies: [],
            publicHeadersPath: ".",
            plugins: [
                .plugin(
                    name: "SwiftGen",
                    package: "MEGABuildTools"
                )
            ]
        ),
        .testTarget(
            name: "MEGASharedRepoL10nTests",
            dependencies: ["MEGASharedRepoL10n"]
        ),
    ]
)
