//
//  CardManagerEnvironment.swift
//  
//
//  Created by Alex Ioja-Yang on 12/07/2022.
//

import Foundation
import CheckoutCardNetworkStub
import CheckoutEventLoggerKit

/// Defines the backend environment for card management operations.
///
/// `CardManagerEnvironment` specifies which backend environment the ``CheckoutCardManager``
/// connects to for all card operations. This determines where card data is stored and processed.
///
/// - Important: Choose the correct environment for your use case. Never use `sandbox` in production
///   applications, as it connects to a non-production backend with different data and security constraints.
///
/// ## Usage
///
/// ```swift
/// @Observable
/// @MainActor
/// class CardService {
///     let cardManager: CheckoutCardManager
///     
///     init(environment: CardManagerEnvironment = .production) {
///         self.cardManager = CheckoutCardManager(
///             designSystem: MyDesignSystem(),
///             environment: environment
///         )
///     }
/// }
///
/// // In your app configuration
/// @main
/// struct MyApp: App {
///     #if DEBUG
///     @State private var cardService = CardService(environment: .sandbox)
///     #else
///     @State private var cardService = CardService(environment: .production)
///     #endif
///     
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(cardService)
///         }
///     }
/// }
/// ```
///
/// - Warning: Ensure you use `.production` for release builds. Cards and data from `.sandbox`
///   are not available in `.production` and vice versa.
///
/// - SeeAlso: ``CheckoutCardManager/init(designSystem:environment:)``
public enum CardManagerEnvironment: String {

    /// Development and testing environment.
    ///
    /// The sandbox environment is designed for development and testing purposes.
    /// It connects to a backend built specifically for development work, allowing
    /// you to test card operations without affecting production data.
    ///
    /// - Note: Use this environment during development, staging, and QA testing.
    ///   Do not use in production builds.
    case sandbox

    /// Production environment for live applications.
    ///
    /// The production environment connects to the live backend system and handles
    /// real card data and transactions. This should only be used in production
    /// applications serving actual end users.
    ///
    /// - Important: Only use this environment in production-ready applications.
    ///   Ensure all testing is complete before deploying with this environment.
    case production

    func networkEnvironment() -> CardNetworkEnvironment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .production
        }
    }

    func loggingEnvironment() -> CheckoutEventLoggerKit.Environment {
        switch self {
        case .sandbox: return .sandbox
        case .production: return .production
        }
    }

}
