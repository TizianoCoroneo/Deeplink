// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Deeplink",
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
