// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interventions",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "Interventions",
            targets: ["Interventions"]),
    ],
    dependencies: [
        .package(name: "FlowKit", path: "../FlowKit")
    ],
    targets: [
        .target(
            name: "Interventions"),
        .testTarget(
            name: "InterventionsTests",
            dependencies: [
                "Interventions",
                .product(name: "FlowKitTestSupport", package: "FlowKit")
            ]),
    ]
)
