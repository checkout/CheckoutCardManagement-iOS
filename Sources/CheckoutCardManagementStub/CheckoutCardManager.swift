//
//  CheckoutCardManager.swift
//
//
//  Created by Alex Ioja-Yang on 8/05/2022.
//

import UIKit
import CheckoutEventLoggerKit
import CheckoutCardNetworkStub

/// Interface required for Card object to share properties with its owner in a delegate pattern
protocol CardManager: AnyObject {
    /// Service enabling interactions with outside services
    var cardService: CardService { get }
    /// Analytics logger enabling tracking events
    var logger: CheckoutLogger? { get }
    /// Generic token used for non sensitive calls
    var sessionToken: String? { get }
    /// Design system to guide any secure view UI
    var designSystem: CardManagementDesignSystem { get }

}

/// The main entry point for all card management operations.
///
/// `CheckoutCardManager` is the primary interface for the Checkout Card Management SDK,
/// providing access to card operations including:
/// - Session authentication and management
/// - Retrieving card lists and details
/// - Apple Wallet push provisioning configuration
/// - Secure display of sensitive card information
/// - Card state management
///
/// **Important:** The manager instance must be retained (stored as a strong reference) throughout
/// the lifetime of any card operations. Do not create the manager as a local variable or allow it
/// to be deallocated while operations are in progress.
///
/// ## Lifecycle
///
/// 1. **Initialization**: Create the manager with a design system and environment
/// 2. **Authentication**: Log in with a session token
/// 3. **Operations**: Perform card operations (retrieve cards, provision to wallet, etc.)
/// 4. **Cleanup**: Log out when done or when switching users
///
/// ## Design System Integration
///
/// The manager uses the provided ``CardManagementDesignSystem`` to style any secure UI components
/// that display sensitive card information. Ensure your design system matches your app's visual style.
///
/// - SeeAlso: ``Card``, ``CardManagementDesignSystem``, ``CardManagerEnvironment``, ``CardManagementError``
public final class CheckoutCardManager: CardManager {

    /// Result type that on success delivers a secure UIView to be presented to the user, and on failure delivers an error to identify problem
    public typealias SecureResult = Result<UIView, CardManagementError>
    /// Completion handler returning a SecureResult
    public typealias SecureResultCompletion = ((SecureResult) -> Void)
    /// Result type that on success delivers secure UIViews for PAN & SecurityCode, and on failure delivers an error to identify problem
    public typealias SecurePropertiesResult = Result<(pan: UIView, securityCode: UIView), CardManagementError>
    /// Completion handler returning a SecurePropertiesResult
    public typealias SecurePropertiesResultCompletion = ((SecurePropertiesResult) -> Void)
    /// Result type that can provide CardList or a network error
    public typealias CardListResult = Result<[Card], CardManagementError>
    /// Completion handler returning CardListResult
    public typealias CardListResultCompletion = ((CardListResult) -> Void)

    public typealias CardDetailResultCompletion = ((Result<Card, CardManagementError>) -> Void)

    /// Generic token used for non sensitive calls
    var sessionToken: String?
    /// Service enabling interactions with outside services
    let cardService: CardService
    /// Design system to guide any secure view UI
    let designSystem: CardManagementDesignSystem
    /// Analytics logger and dispatcher for tracked events
    let logger: CheckoutLogger?

    /// Initializes the Card Manager with the specified design system and environment.
    ///
    /// Creates a new `CheckoutCardManager` instance configured to connect to the specified
    /// backend environment. This is the primary initializer for the SDK and must be called
    /// before performing any card operations.
    ///
    /// The manager automatically sets up logging and analytics tracking, and configures
    /// the connection to Checkout's card management backend based on the environment.
    ///
    /// - Parameters:
    ///   - designSystem: The ``CardManagementDesignSystem`` that defines the visual styling
    ///                   for secure UI components. This design system is used whenever the SDK
    ///                   displays sensitive card information in secure views.
    ///   - environment: The ``CardManagerEnvironment`` specifying which backend to connect to
    ///                  (`.sandbox` for development/testing or `.production` for live apps).
    ///
    /// - Important: Store the created manager as a strong reference (property) of a long-lived
    ///              object. Do not create it as a local variable or allow it to be deallocated
    ///              during card operations.
    ///
    /// - SeeAlso: ``CardManagementDesignSystem``, ``CardManagerEnvironment``
    public init(designSystem: CardManagementDesignSystem, environment: CardManagerEnvironment) {
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)
        let service = CheckoutCardService(environment: environment.networkEnvironment(), logger: logger)

        self.designSystem = designSystem
        self.cardService = service
        self.logger = logger

        logger.setupRemoteLogging(environment: environment,
                                  serviceVersion: type(of: cardService).version)
        logInitialization()
    }

    internal init(service: CardService,
                  designSystem: CardManagementDesignSystem,
                  logger: CheckoutEventLogging? = nil) {
        self.cardService = service
        self.designSystem = designSystem
        if let logger {
            self.logger = CheckoutLogger(eventLogger: logger)
        } else {
            self.logger = nil
        }

        logInitialization()
    }

    /// Authenticates a session by storing the provided token for subsequent operations.
    ///
    /// This method validates and stores the session token that will be used for all authenticated
    /// card operations. You must call this method with a valid token before performing operations
    /// that require authentication, such as ``getCards()`` or card state changes.
    ///
    /// The token is validated immediately upon receipt. If the token format is invalid, the method
    /// returns `false` and any previously stored token is cleared.
    ///
    /// - Parameter token: The session token string obtained from your authentication backend.
    ///                    This token identifies and authorizes the cardholder session.
    ///
    /// - Returns: `true` if the token was accepted and stored successfully, `false` if the token
    ///            format is invalid. Note that a `true` return value only indicates format validity;
    ///            the token may still fail during API calls if it has expired or lacks proper permissions.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // After obtaining token from your backend
    /// let success = cardManager.logInSession(token: sessionToken)
    ///
    /// if success {
    ///     // Token stored successfully, proceed with operations
    ///     let cards = try await cardManager.getCards()
    /// } else {
    ///     // Token format invalid
    ///     print("Invalid token format")
    /// }
    /// ```
    ///
    /// - Important: Call this method after initializing the manager and before attempting any
    ///              authenticated operations. If you receive an ``CardManagementError/authenticationFailure``
    ///              during operations, obtain a new token and call this method again.
    ///
    /// - SeeAlso: ``logoutSession()``, ``CardManagementError/unauthenticated``, ``CardManagementError/authenticationFailure``
    public func logInSession(token: String) -> Bool {
        guard cardService.isTokenValid(token) else {
            sessionToken = nil
            return false
        }
        sessionToken = token
        return true
    }

    /// Removes the current session token, ending the authenticated session.
    ///
    /// This method clears the stored session token, effectively logging out the current session.
    /// After calling this method, any operations requiring authentication will fail with
    /// ``CardManagementError/unauthenticated`` until ``logInSession(token:)`` is called again.
    ///
    /// Call this method when:
    /// - The user explicitly logs out
    /// - Switching between different user accounts
    /// - The session expires or is invalidated
    /// - Your app enters the background for security reasons
    ///
    ///
    /// - SeeAlso: ``logInSession(token:)``
    public func logoutSession() {
        sessionToken = nil
    }

    /// Configures the push provisioning manager for Apple Wallet integration.
    ///
    /// This method initializes the Apple Wallet push provisioning system with the necessary configuration
    /// and card details. This must be called before attempting to provision any cards to Apple Wallet.
    /// The configuration includes cardholder information, app group settings for Wallet Extensions,
    /// and details about cards available for provisioning.
    ///
    /// **Important:** This configuration step is required only once during the provisioning setup process,
    /// typically during app initialization or when the cardholder first sets up Apple Pay.
    ///
    /// - Parameters:
    ///     - cardholderID: The unique identifier for the cardholder who owns the cards
    ///     - appGroupId: The App Group identifier shared between your app and Wallet Extensions, enabling
    ///                   data sharing for the provisioning process
    ///     - configuration: The ``ProvisioningConfiguration`` containing provisioning settings and credentials
    ///     - walletCards: An array of tuples containing ``Card`` objects and their corresponding card art images
    ///                    (``UIImage``) to be displayed in Apple Wallet
    ///     - completionHandler: A closure called with the result indicating either success or failure with a
    ///                         ``CardManagementError``. The completion handler is called on the main thread.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version
    ///         ``configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/pushProvisioningFailure(failure:)`` if the configuration fails
    /// - ``CardManagementError/configurationIssue(hint:)`` if the provided parameters are invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// let cards: [(Card, UIImage)] = [
    ///     (card1, cardArtImage1),
    ///     (card2, cardArtImage2)
    /// ]
    ///
    /// cardManager.configurePushProvisioning(
    ///     cardholderID: "cardholder_123",
    ///     appGroupId: "group.com.example.app",
    ///     configuration: provisioningConfig,
    ///     walletCards: cards
    /// ) { result in
    ///     switch result {
    ///     case .success:
    ///         print("Push provisioning configured successfully")
    ///     case .failure(let error):
    ///         print("Configuration failed: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``ProvisioningConfiguration``, ``Card/provision(provisioningToken:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)")
    public func configurePushProvisioning(cardholderID: String,
                                     appGroupId: String,
                                     configuration: ProvisioningConfiguration,
                                     walletCards: [(Card, UIImage)],
                                     completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await configurePushProvisioning(cardholderID: cardholderID,
                                                    appGroupId: appGroupId,
                                                    configuration: configuration,
                                                    walletCards: walletCards)
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            } catch {
                completionHandler(.failure(.pushProvisioningFailure(failure: .operationFailure)))
            }
        }
    }

    /// Configures the push provisioning manager for Apple Wallet integration.
    ///
    /// This async method initializes the Apple Wallet push provisioning system with the necessary configuration
    /// and card details. This must be called before attempting to provision any cards to Apple Wallet.
    /// The configuration includes cardholder information, app group settings for Wallet Extensions,
    /// and details about cards available for provisioning.
    ///
    /// **Important:** This configuration step is required only once during the provisioning setup process,
    /// typically during app initialization or when the cardholder first sets up Apple Pay.
    ///
    /// - Parameters:
    ///     - cardholderID: The unique identifier for the cardholder who owns the cards
    ///     - appGroupId: The App Group identifier shared between your app and Wallet Extensions, enabling
    ///                   data sharing for the provisioning process
    ///     - configuration: The ``ProvisioningConfiguration`` containing provisioning settings and credentials
    ///     - walletCards: An array of tuples containing ``Card`` objects and their corresponding card art images
    ///                    (``UIImage``) to be displayed in Apple Wallet
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/pushProvisioningFailure(failure:)`` if the configuration fails
    ///   - ``CardManagementError/configurationIssue(hint:)`` if the provided parameters are invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///   - ``CardManagementError/authenticationFailure`` if authentication credentials are invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         let cards: [(Card, UIImage)] = [
    ///             (card1, cardArtImage1),
    ///             (card2, cardArtImage2)
    ///         ]
    ///
    ///         try await cardManager.configurePushProvisioning(
    ///             cardholderID: "cardholder_123",
    ///             appGroupId: "group.com.example.app",
    ///             configuration: provisioningConfig,
    ///             walletCards: cards
    ///         )
    ///         print("Push provisioning configured successfully")
    ///     } catch {
    ///         print("Configuration failed: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``ProvisioningConfiguration``, ``Card/provision(provisioningToken:viewController:)``
    /// - Since: 4.0.0
    public func configurePushProvisioning(
        cardholderID: String,
        appGroupId: String,
        configuration: ProvisioningConfiguration,
        walletCards: [(Card, UIImage)]
    ) async throws {
        let walletCardsList: [WalletCardDetails] = walletCards.map { card, uiImage in
            return WalletCardDetails(
                cardId: card.id,
                cardTitle: card.panLast4Digits,
                cardArt: uiImage
            )
        }

        let startTime = Date()

        do {
            try await cardService.configurePushProvisioning(
                cardholderID: cardholderID,
                appGroupId: appGroupId,
                configuration: configuration,
                walletCardsList: walletCardsList
            )

            let event = LogEvent.configurePushProvisioning(cardholderId: cardholderID)
            logger?.log(event, startedAt: startTime)

        } catch let error as CardNetworkError {
            logger?.log(
                .failure(
                    source: "Configure Push Provisioning",
                    error: error,
                    networkError: error,
                    additionalInfo: ["cardholderId": cardholderID]
                ),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        } catch {
            logger?.log(
                .failure(
                    source: "Configure Push Provisioning",
                    error: error,
                    networkError: nil,
                    additionalInfo: ["cardholderId": cardholderID, "errorMessage": error.localizedDescription]
                ),
                startedAt: startTime
            )
            throw CardManagementError.connectionIssue
        }
    }


    /// Retrieves a list of all cards associated with the authenticated cardholder account.
    ///
    /// This method returns card information including card state, last 4 digits of PAN,
    /// expiry date, cardholder name, and card ID. Each ``Card`` object provides methods for further
    /// card management operations.
    ///
    /// **Important:** This method requires an active session. You must call ``logInSession(token:)`` with a
    /// valid session token before invoking this method.
    ///
    /// - Parameters:
    ///     - completionHandler: A closure called with the result containing either an array of ``Card`` objects or a ``CardManagementError``.
    ///                         Returns an empty array if no cards are found.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version ``getCards()``
    ///
    /// The completion handler receives a `Result` which may contain the following errors:
    /// - ``CardManagementError/unauthenticated`` if no session is active (logInSession not called or session token was rejected)
    /// - ``CardManagementError/authenticationFailure`` if the session token has expired or is no longer valid
    ///   - ``CardManagementError/invalidRequestInput`` if the input is not valid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems or server communication errors
    /// - ``CardManagementError/configurationIssue(hint:)`` if the SDK is misconfigured or the request parameters are invalid (check the hint property for guidance)
    ///
    /// ## Example
    ///
    /// ```swift
    /// cardManager.getCards { result in
    ///     switch result {
    ///     case .success(let cards):
    ///         cards.forEach { card in
    ///             print("Card: \(card.panLast4Digits)")
    ///         }
    ///     case .failure(let error):
    ///         switch error {
    ///         case .unauthenticated:
    ///             // Prompt login
    ///         case .connectionIssue:
    ///             // Show network error
    ///         default:
    ///             // Handle other errors
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``Card``, ``logInSession(token:)``
    /// - Parameters:
    ///   - statuses: Optional set of card states to filter the results
    ///   - completionHandler: Callback with the list of cards or an error
    @available(*, deprecated, renamed: "getCards(statuses:)")
    public func getCards(statuses: Set<CardState>? = nil,
                         completionHandler: @escaping CardListResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let cards = try await getCards(statuses: statuses)
                completionHandler(.success(cards))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Retrieves a list of all cards associated with the authenticated cardholder account.
    ///
    /// This async method returns card information including card state, last 4 digits of PAN,
    /// expiry date, cardholder name, and card ID. Each ``Card`` object provides methods for further
    /// card management operations.
    ///
    /// **Important:** This method requires an active session. You must call ``logInSession(token:)`` with a
    /// valid session token before invoking this method.
    ///
    /// - Returns: An array of ``Card`` objects containing all cards associated with the account. Returns an empty array
    ///           if no cards are found.
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/unauthenticated`` if no session is active (logInSession not called or session token was rejected)
    ///   - ``CardManagementError/authenticationFailure`` if the session token has expired or is no longer valid
    ///   - ``CardManagementError/invalidRequestInput`` if the input is not valid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems or server communication errors
    ///   - ``CardManagementError/configurationIssue(hint:)`` if the SDK is misconfigured or the request parameters are invalid (check the hint property for guidance)
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         let cards = try await cardManager.getCards()
    ///         // print your cards
    ///     } catch let error as CardManagementError {
    ///         switch error {
    ///         case .unauthenticated:
    ///             // Prompt login
    ///         case .connectionIssue:
    ///             // Show network error
    ///         default:
    ///             // Handle other errors
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``Card``, ``logInSession(token:)``
    /// - Since: 4.0.0
    public func getCards(statuses: Set<CardState>? = nil) async throws -> [Card] {
        guard let sessionToken = sessionToken else {
            throw CardManagementError.unauthenticated
        }

        let startTimestamp = Date()
        do {
            let cards = try await cardService.getCards(sessionToken: sessionToken, statuses: statuses).compactMap {
                Card(networkCard: $0, manager: self)
            }

            let cardIds: [String] = cards.compactMap { $0.id }
            logger?.log(.cardList(cardIds: cardIds), startedAt: startTimestamp)
            return cards
        } catch let error as CardNetworkError {
            logger?.log(
                .failure(source: "Get Cards",
                         error: error,
                         networkError: error,
                         additionalInfo: [:]),
                startedAt: startTimestamp
            )
            throw CardManagementError.from(error)
        } catch {
            logger?.log(
                .failure(source: "Get Cards",
                         error: error,
                         additionalInfo: [:]),
                startedAt: startTimestamp
            )

            throw CardManagementError.connectionIssue
        }
    }

    /// Retrieves detailed information for a specific card by its identifier.
    ///
    /// This method fetches the details of a single card using its unique card ID. The returned
    /// `Card` object provides access to card properties and operations.
    ///
    /// - Important: A valid session token must be set using `logInSession(token:)` before calling
    ///   this method. If no session token is available, the completion handler will be called
    ///   immediately with a `.failure(.unauthenticated)` result.
    ///
    /// - Parameters:
    ///   - cardID: The unique identifier of the card to retrieve. This should be a valid card ID
    ///     associated with the authenticated cardholder.
    /// - Returns: A ``Card`` object with its properties and releated operations.
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/unauthenticated`` if no session is active (logInSession not called or session token was rejected)
    ///   - ``CardManagementError/authenticationFailure`` if the session token has expired or is no longer valid
    ///   - ``CardManagementError/invalidRequestInput`` if the input is not valid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems or server communication errors
    ///   - ``CardManagementError/notFound`` if the card is not found
    ///   - ``CardManagementError/configurationIssue(hint:)`` if the SDK is misconfigured or the request parameters are invalid (check the hint property for guidance)
    ///
    /// ## Example Usage
    /// ```swift
    /// Task {
    ///     do {
    ///         let cards = try await cardManager.getCard(withID: "<id>")
    ///         // print your cards
    ///     } catch let error as CardManagementError {
    ///         switch error {
    ///         case .unauthenticated:
    ///             // Prompt login
    ///         case .connectionIssue:
    ///             // Show network error
    ///         default:
    ///             // Handle other errors
    ///         }
    ///     }
    /// }
    /// ```
    /// - Since: 4.0.0
    public func getCard(withID cardID: String) async throws -> Card {
        guard let sessionToken = sessionToken else {
            throw CardManagementError.unauthenticated
        }

        let startTimestamp = Date()

        do {
            let card = try await cardService.getCard(withID: cardID, sessionToken: sessionToken)
            logger?.log(.cardDetails(cardID: card.id), startedAt: startTimestamp)
            return Card(networkCard: card, manager: self)
        } catch let error as CardNetworkError {
            logger?.log(
                .failure(source: "Get Card Details",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardID": cardID]),
                startedAt: startTimestamp
            )
            throw CardManagementError.from(error)
        } catch {
            logger?.log(
                .failure(source: "Get Card Details",
                         error: error,
                         additionalInfo: ["cardID": cardID]),
                startedAt: startTimestamp
            )

            throw CardManagementError.connectionIssue
        }
    }

    /// Retrieves detailed information for a specific card by its identifier.
    ///
    /// This method fetches the details of a single card using its unique card ID. The returned
    /// `Card` object provides access to card properties and operations.
    ///
    /// - Important: A valid session token must be set using `logInSession(token:)` before calling
    ///   this method. If no session token is available, the completion handler will be called
    ///   immediately with a `.failure(.unauthenticated)` result.
    ///
    /// - Parameters:
    ///   - cardID: The unique identifier of the card to retrieve. This should be a valid card ID
    ///     associated with the authenticated cardholder.
    ///   - completionHandler: A closure called when the request completes. The closure receives
    ///     a `Result<Card, CardManagementError>` containing either:
    ///     - `.success(Card)`: A `Card` object containing the card's details
    ///     - `.failure(CardManagementError)`: An error indicating why the request failed, such as
    ///       `.unauthenticated` if no session token is set, or `.connectionIssue` if the network
    ///       request failed
    ///
    /// - Note: This method logs analytics events for both successful and failed requests,
    ///   including request duration and the card ID.
    ///
    /// ## Example Usage
    /// ```swift
    /// manager.getCard(withID: "card_123") { result in
    ///     switch result {
    ///     case .success(let card):
    ///         print("Card: \(card.displayName)")
    ///         print("Last 4 digits: \(card.panLast4Digits)")
    ///         print("State: \(card.state)")
    ///     case .failure(let error):
    ///         print("Failed to get card: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    ///
    /// - Since: 3.3.0

    @available(*, deprecated, renamed: "getCard(withID:)")
    public func getCard(withID cardID: String,
                        completionHandler: @escaping CardDetailResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let card = try await getCard(withID: cardID)
                completionHandler(.success(card))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    private func logInitialization() {
        logger?.log(.initialized(design: designSystem))
    }
}
