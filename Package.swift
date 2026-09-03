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
        url: "https://github.com/checkout/CheckoutCardManagement-iOS/releases/download/4.2.0/CheckoutCardNetwork.xcframework.zip",
        checksum: "86e6e785e74b260359764552efaae2b5e2a60eb16134286e5d21dcdd62019499"
    ),
        .binaryTarget(
            name: "CheckoutCardNetworkStub",
            path: "SupportFrameworks/CheckoutCardNetworkStub.xcframework"),
        .binaryTarget(
        name: "CheckoutOOBSDK",
        url: "https://github.com/checkout/CheckoutCardManagement-iOS/releases/download/4.2.0/CheckoutOOBSDK.xcframework.zip",
        checksum: "fb193ce4fbea8643129121d6f3f3ca74c5f53168c5cf777bf644514a196a2f44"
    ),
    ]
)
