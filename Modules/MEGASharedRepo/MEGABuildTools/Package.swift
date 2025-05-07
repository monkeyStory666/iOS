// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MEGABuildTools",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .plugin(
            name: "SwiftLint",
            targets: ["SwiftLint"]
        ),
        .plugin(
            name: "SwiftGen",
            targets: ["SwiftGen"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.57.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "a1bbafe57538077f3abe4cfb004b0464dcd87e8c23611a2153c675574b858b3a"
        ),
        .binaryTarget(
            name: "SwiftGenBinary",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool(),
            dependencies: ["SwiftLintBinary"]
        ),
        .plugin(
            name: "SwiftGen",
            capability: .buildTool(),
            dependencies: ["SwiftGenBinary"]
        )
    ]
)
