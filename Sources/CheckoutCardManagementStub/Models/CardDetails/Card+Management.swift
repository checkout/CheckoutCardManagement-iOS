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

    /// Get the Card Digitization State
    ///
    /// - Parameters:
    ///     - completionHandler: Completion Handler returning the outcome of the fetch digitization state operation
    func getDigitizationState(provisioningToken: String,
                              completionHandler: @escaping ((CheckoutCardManager.CardDigitizationResult) -> Void)) {
        let startTime = Date()
        manager?.cardService.getCardDigitizationState(cardID: self.id,
                                                      token: provisioningToken) { [weak self] result in
            switch result {
            case .success(let cardDigitizationData):
                let digitizationData = DigitizationData.from(cardDigitizationData)
                let event = LogEvent.getCardDigitizationState(cardId: self?.id ?? "",
                                                              digitizationState: digitizationData.state)
                self?.manager?.logger?.log(event, startedAt: startTime)
                completionHandler(.success(digitizationData))
            case .failure(let networkError):
                self?.manager?.logger?.log(
                    .failure(source: "Get Digitization State",
                             error: networkError,
                             networkError: networkError,
                             additionalInfo: ["cardId": self?.id ?? ""]),
                    startedAt: startTime
                )
                completionHandler(.failure(.from(networkError)))
            }
        }
    }

    /// Add the card object to the Apple Wallet
    ///
    /// - Parameters:
    ///     - cardhodlerID: Identifier for the cardholder owning the card
    ///     - completionHandler: Completion Handler returning the outcome of the provisioning operation
    func provision(provisioningToken: String,
                   completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        let startTime = Date()
        manager?.cardService.addCardToAppleWallet(cardID: self.id,
                                                  token: provisioningToken) { [weak self] result in
            switch result {
            case .success:
                let event = LogEvent.pushProvisioning(cardId: self?.id ?? "")
                self?.manager?.logger?.log(event, startedAt: startTime)
                completionHandler(.success)
            case .failure(let networkError):
                self?.manager?.logger?.log(
                    .failure(
                        source: "Push Provisioning",
                        error: networkError,
                        networkError: networkError,
                        additionalInfo: ["cardId": self?.id ?? ""]),
                    startedAt: startTime)
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
            let event = LogEvent.stateManagement(cardId: id,
                                                 originalState: state,
                                                 requestedState: newState,
                                                 reason: reasonString)
            manager?.logger?.log(event, startedAt: startTime)
            state = newState
            completionHandler(.success)
        case .failure(let networkError):
            manager?.logger?.log(
                .failure(source: operationSource,
                         error: networkError,
                         networkError: networkError,
                         additionalInfo: ["cardId": id, "originalState": state, "newState": newState, "reason": reasonString ?? ""]),
                startedAt: startTime)
            completionHandler(.failure(.from(networkError)))
        }
    }

}
