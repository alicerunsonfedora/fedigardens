// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenGate",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GardenGate",
            targets: ["GardenGate"])
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice"),
        .package(name: "FlowKit", path: "../FlowKit"),
        .package(url: "https://github.com/alicerunsonfedora/SafariView", branch: "root")
    ],
    targets: [
        .target(
            name: "GardenGate",
            dependencies: ["Alice", "FlowKit", "SafariView"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "GardenGateTests",
            dependencies: [
                "GardenGate",
                "Alice",
                .product(name: "AliceMockingbird", package: "Alice"),
                .product(name: "FlowKitTestSupport", package: "FlowKit")
            ])
    ]
)
