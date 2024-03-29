// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenSettings",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "GardenSettings",
            targets: ["GardenSettings"])
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice")
    ],
    targets: [
        .target(
            name: "GardenSettings",
            dependencies: [
                .product(name: "Alice", package: "Alice")
            ]),
        .testTarget(
            name: "GardenSettingsTests",
            dependencies: ["GardenSettings"])
    ]
)
