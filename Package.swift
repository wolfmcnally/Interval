// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Interval",
    products: [
        .library(
            name: "Interval",
            targets: ["Interval"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Interval",
            dependencies: []),
        .testTarget(
            name: "IntervalTests",
            dependencies: ["Interval"]),
    ]
)
