// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenGate",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GardenGate",
            targets: ["GardenGate"])
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice"),
        .package(name: "FlowKit", path: "../FlowKit")
    ],
    targets: [
        .target(
            name: "GardenGate",
            dependencies: ["Alice", "FlowKit"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "GardenGateTests",
            dependencies: [
                "GardenGate",
                "Alice",
                .product(name: "AliceMockingbird", package: "Alice")
            ])
    ]
)
