// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CheckoutCardManagement-iOS",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "CheckoutCardManagement",
            targets: ["CheckoutCardManagement"]),
        .library(
            name: "CheckoutOOBSDK",
            targets: ["CheckoutOOBSDK"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/checkout/checkout-event-logger-ios-framework",
            exact: "1.2.4"),
        .package(
            url: "https://github.com/checkout/NetworkClient-iOS.git",
            exact: "1.1.2"),
    ],
    targets: [
        .target(
            name: "CheckoutCardManagement",
            dependencies: [
                .product(
                    name: "CheckoutEventLoggerKit",
                    package: "checkout-event-logger-ios-framework"),
                .product(
                    name: "CheckoutNetwork",
                    package: "NetworkClient-iOS"),
                "CheckoutCardNetwork",
            ]),
        .target(
            name: "CheckoutCardManagementStub",
            dependencies: [
                .product(
                    name: "CheckoutEventLoggerKit",
                    package: "checkout-event-logger-ios-framework"),
                .product(
                    name: "CheckoutNetwork",
                    package: "NetworkClient-iOS"),
                "CheckoutCardNetworkStub",
            ]),
        .binaryTarget(
        name: "CheckoutCardNetwork",
        url: "https://github.com/checkout/CheckoutCardManagement-iOS/releases/download/5.1.0/CheckoutCardNetwork.xcframework.zip",
        checksum: "f75a422e3d373f1d0632939583d5ad98ad17b52bceb741485533272f51b6be94"
    ),
        .binaryTarget(
            name: "CheckoutCardNetworkStub",
            path: "SupportFrameworks/CheckoutCardNetworkStub.xcframework"),
        .binaryTarget(
        name: "CheckoutOOBSDK",
        url: "https://github.com/checkout/CheckoutCardManagement-iOS/releases/download/5.1.0/CheckoutOOBSDK.xcframework.zip",
        checksum: "84a0b0e99077103893eb4b1a5012d8b96a5fa22f89cf4a1f47ada0a1fc157903"
    ),
    ]
)
