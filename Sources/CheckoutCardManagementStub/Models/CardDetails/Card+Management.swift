//
//  Card+Management.swift
//  
//
//  Created by Alex Ioja-Yang on 19/01/2023.
//

import Foundation
import CheckoutCardNetworkStub

public extension Card {
    
    /// Possible Card State changes from the current state
    var possibleStateChanges: [CardState] {
        switch self.state {
        case .inactive, .suspended:
            return [.active, .revoked]
        case .active:
            return [.suspended, .revoked]
        case .revoked:
            return []
        }
    }
    
    /// Add the card object to the Apple Wallet
    ///
    /// - Parameters:
    ///     - cardhodlerID: Identifier for the cardholder owning the card
    ///     - configuration: Specialised object used for Push Provisioning, received during Onboarding
    ///     - provisioningToken: Push Provisioning token
    ///     - completionHandler: Completion Handler returning the outcome of the provisioning operation
    func provision(cardholderID: String,
                   configuration: ProvisioningConfiguration,
                   provisioningToken: String,
                   completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        let startTime = Date()
        manager?.cardService.addCardToAppleWallet(cardID: self.id,
                                                  cardholderID: cardholderID,
                                                  configuration: configuration,
                                                  token: provisioningToken) { [weak self] result in
            switch result {
            case .success:
                let event = LogEvent.pushProvisioning(last4CardID: self?.partIdentifier ?? "",
                                                      last4CardholderID: String(cardholderID.suffix(4)))
                self?.manager?.logger?.log(event, startedAt: startTime)
                completionHandler(.success)
            case .failure(let networkError):
                self?.manager?.logger?.log(.failure(source: "Push Provisioning", error: networkError), startedAt: startTime)
                completionHandler(.failure(.from(networkError)))
            }
        }
    }
    
    /// Request to activate the card
    func activate(completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        guard possibleStateChanges.contains(.active) else {
            completionHandler(.failure(.invalidStateRequested))
            return
        }
        guard let sessionToken = manager?.sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTime = Date()
        
        manager?.cardService.activateCard(cardID: id,
                                          sessionToken: sessionToken) { [weak self] result in
            self?.handleCardOperationResult(result: result,
                                            newState: .active,
                                            startTime: startTime,
                                            operationSource: "Activate Card",
                                            completionHandler: completionHandler)
        }
    }
    
    /// Request to suspend the card, with option to provide a reason for change
    func suspend(reason: CardSuspendReason?,
                 completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        guard possibleStateChanges.contains(.suspended) else {
            completionHandler(.failure(.invalidStateRequested))
            return
        }
        guard let sessionToken = manager?.sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTime = Date()
        
        manager?.cardService.suspendCard(cardID: id,
                                         reason: reason,
                                         sessionToken: sessionToken) { [weak self] result in
            self?.handleCardOperationResult(result: result,
                                            newState: .suspended,
                                            reasonString: reason?.rawValue,
                                            startTime: startTime,
                                            operationSource: "Suspend Card",
                                            completionHandler: completionHandler)
        }
    }
    
    /// Request to revoke the card, with option to provide a reason for change
    func revoke(reason: CardRevokeReason?,
                completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        guard possibleStateChanges.contains(.revoked) else {
            completionHandler(.failure(.invalidStateRequested))
            return
        }
        guard let sessionToken = manager?.sessionToken else {
            completionHandler(.failure(.unauthenticated))
            return
        }
        let startTime = Date()
        
        manager?.cardService.revokeCard(cardID: id,
                                        reason: reason,
                                        sessionToken: sessionToken) { [weak self] result in
            self?.handleCardOperationResult(result: result,
                                            newState: .revoked,
                                            reasonString: reason?.rawValue,
                                            startTime: startTime,
                                            operationSource: "Revoke Card",
                                            completionHandler: completionHandler)
        }
    }
    
    private func handleCardOperationResult(result: OperationResult,
                                           newState: CardState,
                                           reasonString: String? = nil,
                                           startTime: Date,
                                           operationSource: String,
                                           completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        switch result {
        case .success:
            let event = LogEvent.stateManagement(idLast4: partIdentifier,
                                                 originalState: state,
                                                 requestedState: newState,
                                                 reason: reasonString)
            manager?.logger?.log(event, startedAt: startTime)
            state = newState
            completionHandler(.success)
        case .failure(let networkError):
            manager?.logger?.log(.failure(source: operationSource, error: networkError), startedAt: startTime)
            completionHandler(.failure(.from(networkError)))
        }
    }
    
}
