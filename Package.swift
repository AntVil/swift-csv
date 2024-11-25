// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-csv",
    products: [
        .library(
            name: "swiftCsv",
            targets: ["swiftCsv"]
        ),
    ],
    targets: [
        .target(
            name: "swiftCsv"
        ),
        .testTarget(
            name: "swiftCsvTests",
            dependencies: ["swiftCsv"]
        ),
    ]
)
