// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowKit",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        .library(
            name: "FlowKit",
            targets: ["FlowKit"]),
        .library(
            name: "FlowKitTestSupport",
            targets: ["FlowKitTestSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "FlowKit"),
        .target(
            name: "FlowKitTestSupport",
            dependencies: ["FlowKit"]),
        .testTarget(
            name: "FlowKitTests",
            dependencies: ["FlowKit"])
    ]
)
