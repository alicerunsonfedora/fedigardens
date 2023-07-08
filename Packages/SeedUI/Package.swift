// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SeedUI",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "SeedUI",
            targets: ["SeedUI"])
    ],
    targets: [
        .target(
            name: "SeedUI")
    ]
)
