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

    /// Request a list of cards
    public func getCards(completionHandler: @escaping CardListResultCompletion) {
        guard let sessionToken = sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTimestamp = Date()
        cardService.getCards(sessionToken: sessionToken) { [weak self] in
            switch $0 {
            case .success(let cards):
                let cards = cards.compactMap {
                    Card(networkCard: $0, manager: self)
                }
                let cardsSuffixes: [String] = cards.compactMap { $0.partIdentifier }
                self?.logger?.log(.cardList(idSuffixes: cardsSuffixes), startedAt: startTimestamp)
                completionHandler(.success(cards))
            case .failure(let networkError):
                self?.logger?.log(.failure(source: "Get Cards", error: networkError), startedAt: startTimestamp)
                completionHandler(.failure(.from(networkError)))
            }
        }
    }
    
    private func logInitialization() {
        logger?.log(.initialized(design: designSystem))
    }
}

