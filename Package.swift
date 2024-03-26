// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CheckoutCardManagement-iOS",
  platforms: [
    .iOS(.v12),
  ],
  products: [
    .library(
      name: "CheckoutCardManagement",
      targets: ["CheckoutCardManagement", "CheckoutCardManagementStub"]),
    .library(
      name: "CheckoutOOBSDK",
      targets: ["CheckoutOOBSDK"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/checkout/checkout-event-logger-ios-framework.git",
      exact: "1.2.4"),
    .package(
      url: "https://github.com/checkout/NetworkClient-iOS.git",
      exact: "1.1.1"),
    .package(
      url: "https://github.com/Kitura/Swift-JWT.git",
      exact: "4.0.1")
  ],
  targets: [
    .target(
      name: "CheckoutCardManagement",
      dependencies: [
        .product(name: "CheckoutNetwork",
                 package: "NetworkClient-iOS"),
        .product(name: "SwiftJWT",
                 package: "Swift-JWT"),
        .product(name: "CheckoutEventLoggerKit",
                 package: "checkout-event-logger-ios-framework"),
        "CheckoutCardNetwork",
      ]),
    .target(
      name: "CheckoutCardManagementStub",
      dependencies: [
        .product(
          name: "CheckoutEventLoggerKit",
          package: "checkout-event-logger-ios-framework"),
        "CheckoutCardNetworkStub",
      ]),
    .binaryTarget(
      name: "CheckoutCardNetwork",
      path: "SupportFrameworks/CheckoutCardNetwork.xcframework"),
    .binaryTarget(
      name: "CheckoutCardNetworkStub",
      path: "SupportFrameworks/CheckoutCardNetworkStub.xcframework"),
    .binaryTarget(
      name: "CheckoutOOBSDK",
      path: "SupportFrameworks/CheckoutOOBSDK.xcframework"),
  ]
)
