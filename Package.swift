// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Deeplink",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
    ],
    products: [
        .library(
            name: "Deeplink",
            targets: ["Deeplink"]),
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
