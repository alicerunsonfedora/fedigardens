// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenProfiles",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GardenProfiles",
            targets: ["GardenProfiles"]),
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice"),
        .package(name: "FrugalMode", path: "../FrugalMode"),
        .package(name: "GardenSettings", path: "../GardenSettings")
    ],
    targets: [
        .target(
            name: "GardenProfiles",
            dependencies: ["Alice", "FrugalMode", "GardenSettings"]),
        .testTarget(
            name: "GardenProfilesTests",
            dependencies: ["GardenProfiles"]),
    ]
)
