// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CheckoutCardManagement-iOS",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "CheckoutCardManagement",
            targets: ["CheckoutCardManagement"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/checkout/checkout-event-logger-ios-framework",
            from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "CheckoutCardManagement",
            dependencies: [
                .product(
                    name: "CheckoutEventLoggerKit",
                    package: "checkout-event-logger-ios-framework"),
                "CheckoutCardNetwork",
            ]),
        .binaryTarget(
            name: "CheckoutCardNetwork",
            path: "SupportFrameworks/CheckoutCardNetwork.xcframework"),
    ]
)
