// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebString",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(
            name: "WebString",
            targets: ["WebString"])
    ],
    dependencies: [
        .package(url: "https://gitlab.com/mflint/HTML2Markdown", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "WebString",
            dependencies: ["HTML2Markdown"]),
        .testTarget(
            name: "WebStringTests",
            dependencies: ["WebString"])
    ]
)
