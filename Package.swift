// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pamir",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "CheckoutCardManagement",
            targets: ["CheckoutCardManagement"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CheckoutCardManagement",
            dependencies: [
                "CheckoutEventLoggerKit",
                "CheckoutCardNetwork",
            ]),
        .binaryTarget(
            name: "CheckoutCardNetwork",
            path: "SupportFrameworks/CheckoutCardNetwork.xcframework"),
        .binaryTarget(
            name: "CheckoutEventLoggerKit",
            path: "SupportFrameworks/CheckoutEventLoggerKit.xcframework"),
    ]
)
