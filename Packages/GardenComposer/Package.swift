// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenComposer",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GardenComposer",
            targets: ["GardenComposer"]),
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice"),
        .package(name: "FlowKit", path: "../FlowKit"),
        .package(name: "GardenSettings", path: "../GardenSettings")
    ],
    targets: [
        .target(
            name: "GardenComposer",
            dependencies: ["Alice", "FlowKit", "GardenSettings"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "GardenComposerTests",
            dependencies: [
                "GardenComposer",
                .product(name: "AliceMockingbird", package: "Alice"),
                .product(name: "FlowKitTestSupport", package: "FlowKit")
            ]),
    ]
)
