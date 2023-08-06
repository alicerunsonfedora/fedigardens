// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GardenDiscussions",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GardenDiscussions",
            targets: ["GardenDiscussions"])
    ],
    dependencies: [
        .package(name: "Alice", path: "../Alice"),
        .package(name: "FrugalMode", path: "../FrugalMode"),
        .package(name: "GardenProfiles", path: "../GardenProfiles"),
        .package(name: "GardenSettings", path: "../GardenSettings"),
        .package(name: "WebString", path: "../WebString"),
        .package(url: "https://github.com/divadretlaw/EmojiText", from: "2.8.0")
    ],
    targets: [
        .target(
            name: "GardenDiscussions",
            dependencies: ["Alice", "FrugalMode", "GardenProfiles", "GardenSettings", "WebString", "EmojiText"]),
        .testTarget(
            name: "GardenDiscussionsTests",
            dependencies: ["GardenDiscussions"])
    ]
)
