//
//  CheckoutCardManager.swift
//
//
//  Created by Alex Ioja-Yang on 8/05/2022.
//

import UIKit
import CheckoutEventLoggerKit
import CheckoutCardNetwork

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

/// Access gateway into the Card Management functionality
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

    /// Enable the functionality using the provided design system for secure UI components
    public init(designSystem: CardManagementDesignSystem, environment: CardManagerEnvironment) {
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)
        let service = CheckoutCardService(environment: environment.networkEnvironment())
        service.logger = logger

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

    /// Store provided token to use on network calls. If token is rejected, any previous session token will be removed.
    public func logInSession(token: String) -> Bool {
        guard cardService.isTokenValid(token) else {
            sessionToken = nil
            return false
        }
        sessionToken = token
        return true
    }

    /// Remove current token from future calls
    public func logoutSession() {
        sessionToken = nil
    }

    // Configure the Push Provisioning Manager
    public func configurePushProvisioning(cardholderID: String,
                                     appGroupId: String,
                                     configuration: ProvisioningConfiguration,
                                     walletCards: [(Card, UIImage)],
                                     completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {

        let walletCardsList: [WalletCardDetails] = walletCards.map { card, uiImage in
            return WalletCardDetails(cardId: card.id, cardTitle: card.panLast4Digits, cardArt: uiImage)
        }

        let startTime = Date()
        cardService.configurePushProvisioning(cardholderID: cardholderID,
                                              appGroupId: appGroupId,
                                              configuration: configuration,
                                              walletCardsList: walletCardsList) { [weak self] in
            switch $0 {
            case .success:
                let event = LogEvent.configurePushProvisioning(cardholderId: cardholderID)
                self?.logger?.log(event, startedAt: startTime)
                completionHandler(.success)
            case .failure(let networkError):
                self?.logger?.log(
                    .failure(source: "Configure Push Provisioning",
                             error: networkError,
                             networkError: networkError,
                             additionalInfo: ["cardholderId": cardholderID]),
                    startedAt: startTime
                )
                completionHandler(.failure(.from(networkError)))
            }
        }
    }

    /// Request a list of cards
    /// - Parameters:
    ///   - statuses: Optional set of card states to filter the results
    ///   - completionHandler: Callback with the list of cards or an error
    public func getCards(statuses: Set<CardState>? = nil,
                         completionHandler: @escaping CardListResultCompletion) {
        guard let sessionToken = sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTimestamp = Date()
        cardService.getCards(sessionToken: sessionToken, statuses: statuses) { [weak self] in
            switch $0 {
            case .success(let cards):
                let cards = cards.compactMap {
                    Card(networkCard: $0, manager: self)
                }
                let cardIds: [String] = cards.compactMap { $0.id }
                self?.logger?.log(.cardList(cardIds: cardIds), startedAt: startTimestamp)
                completionHandler(.success(cards))
            case .failure(let networkError):
                self?.logger?.log(
                    .failure(source: "Get Cards",
                             error: networkError,
                             additionalInfo: [:]),
                    startedAt: startTimestamp
                )
                completionHandler(.failure(.from(networkError)))
            }
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
    public func getCard(withID cardID: String, completionHandler: @escaping CardDetailResultCompletion) {
        guard let sessionToken = sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTimestamp = Date()
        cardService.getCard(withID: cardID, sessionToken: sessionToken) { [weak self] in
            switch $0 {
            case .success(let domainCard):
                let card = Card(networkCard: domainCard, manager: self)
                self?.logger?.log(.cardDetails(cardID: card.id), startedAt: startTimestamp)
                completionHandler(.success(card))
            case .failure(let networkError):
                self?.logger?.log(
                    .failure(source: "Get Card Details",
                             error: networkError,
                             additionalInfo: [:]),
                    startedAt: startTimestamp
                )
                completionHandler(.failure(.from(networkError)))
            }
        }
    }

    private func logInitialization() {
        logger?.log(.initialized(design: designSystem))
    }
}
