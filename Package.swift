// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-csv",
    products: [
        .library(
            name: "swift-csv",
            targets: ["swift-csv"]
        ),
    ],
    targets: [
        .target(
            name: "swift-csv"
        ),
        .testTarget(
            name: "swift-csvTests",
            dependencies: ["swift-csv"]
        ),
    ]
)
