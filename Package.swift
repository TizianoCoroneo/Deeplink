// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Deeplink",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_10),
    ],
    products: [
        .library(
            name: "Deeplink",
            targets: ["Deeplink"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Deeplink",
            dependencies: []),
        .testTarget(
            name: "DeeplinkTests",
            dependencies: ["Deeplink"]),
    ]
)
