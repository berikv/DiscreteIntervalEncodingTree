// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscreteIntervalEncodingTree",
    products: [
        .library(
            name: "DiscreteIntervalEncodingTree",
            targets: ["DiscreteIntervalEncodingTree"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DiscreteIntervalEncodingTree",
            dependencies: []),
        .testTarget(
            name: "DiscreteIntervalEncodingTreeTests",
            dependencies: ["DiscreteIntervalEncodingTree"]),
    ]
)
