//
//  Card+Management.swift
//  
//
//  Created by Alex Ioja-Yang on 19/01/2023.
//

import Foundation
import UIKit
import CheckoutCardNetwork

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

    /// Retrieves the digitization state of the card for Apple Pay provisioning.
    ///
    /// This async method checks whether the card has been added to Apple Wallet and retrieves its
    /// current digitization status. This is useful for determining if a card is already provisioned
    /// before attempting to add it to Apple Wallet.
    ///
    /// - Parameters:
    ///     - provisioningToken: The provisioning token required to authenticate the digitization state request
    ///
    /// - Returns: ``DigitizationData`` containing the card's current digitization state and related information
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/fetchDigitizationStateFailure(failure:)`` if the request fails or returns invalid data
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///   - ``CardManagementError/authenticationFailure`` if the provisioning token is invalid or expired
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         let digitizationData = try await card.getDigitizationState(provisioningToken: token)
    ///         print("Digitization state: \(digitizationData.state)")
    ///     } catch {
    ///         print("Failed to fetch digitization state: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``DigitizationData``, ``provision(provisioningToken:viewController:)``
    /// - Since: 4.0.0
    func getDigitizationState(provisioningToken: String) async throws -> DigitizationData {
        let startTime = Date()
        do {
            guard let manager = manager else {
                throw CardManagementError.fetchDigitizationStateFailure(failure: .operationFailure)
            }
            
            let cardDigitizationData = try await manager.cardService.getCardDigitizationState(
                cardID: self.id,
                token: provisioningToken
            )
            let digitizationData = DigitizationData.from(cardDigitizationData)
            let event = LogEvent.getCardDigitizationState(cardId: self.id, digitizationState: digitizationData.state)

            manager.logger?.log(event, startedAt: startTime)

            return digitizationData

        } catch let error as CardNetworkError {
            self.manager?.logger?.log(
            .failure(source: "Get Digitization State",
                     error: error,
                     networkError: error,
                     additionalInfo: ["cardId": self.id]),
            startedAt: startTime)

            throw CardManagementError.from(error)
        }
    }

    /// Provisions the card to Apple Wallet for contactless payments.
    ///
    /// This method adds the card to Apple Wallet on the device, allowing the cardholder to make
    /// contactless payments using Apple Pay. The provisioning process requires a valid provisioning token
    /// and must be initiated from a view controller to display the Apple Pay provisioning UI.
    ///
    /// **Important:** This method is main actor isolated as it presents UI. The provisioning
    /// process will display Apple's standard card addition flow.
    ///
    /// - Parameters:
    ///     - provisioningToken: The provisioning token required to authenticate and provision the card to Apple Wallet
    ///     - viewController: The view controller to present the Apple Pay provisioning UI from
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/pushProvisioningFailure(failure:)`` if the provisioning request fails
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///   - ``CardManagementError/authenticationFailure`` if the provisioning token is invalid or expired
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task { @MainActor in
    ///     do {
    ///         try await card.provision(provisioningToken: token, viewController: self)
    ///         print("Card successfully added to Apple Wallet")
    ///     } catch {
    ///         print("Failed to provision card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``getDigitizationState(provisioningToken:)``, ``provision(provisioningToken:completionHandler:)``
    /// - Since: 4.0.0
    @MainActor
    func provision(provisioningToken: String, viewController: UIViewController) async throws {
        let startTime = Date()

        do {
            try await manager?.cardService.addCardToAppleWallet(cardID: self.id, token: provisioningToken, viewController: viewController)

            let event = LogEvent.pushProvisioning(cardId: self.id)
            self.manager?.logger?.log(event, startedAt: startTime)
        } catch let error as CardNetworkError {
            self.manager?.logger?.log(
                .failure(
                    source: "Push Provisioning",
                    error: error,
                    networkError: error,
                    additionalInfo: ["cardId": self.id]),
                startedAt: startTime)
            throw CardManagementError.from(error)
        } catch {
            self.manager?.logger?.log(
                .failure(
                    source: "Push Provisioning",
                    error: error,
                    networkError: nil,
                    additionalInfo: ["cardId": self.id, "errorMessage": error.localizedDescription]),
                startedAt: startTime)
            throw CardManagementError.connectionIssue
        }
    }

    /// Activates the card, transitioning it to an active state for transactions.
    ///
    /// This method transitions the card from an inactive or suspended state to active, allowing the
    /// cardholder to use it for purchases and other transactions. The card must be in a state that
    /// permits activation (check ``possibleStateChanges`` for valid transitions).
    ///
    /// **Important:** This method requires an active session. You must call ``CheckoutCardManager/logInSession(token:)``
    /// with a valid session token before invoking this method.
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/invalidStateRequested`` if the card cannot be activated from its current state
    ///   - ``CardManagementError/unauthenticated`` if no session is active
    ///   - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         try await card.activate()
    ///         print("Card activated successfully")
    ///     } catch {
    ///         print("Failed to activate card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``suspend(reason:)``, ``revoke(reason:)``
    /// - Since: 4.0.0
    func activate() async throws {
        guard possibleStateChanges.contains(.active) else {
            throw CardManagementError.invalidStateRequested
        }
        guard let manager = manager, let sessionToken = manager.sessionToken else {
            throw CardManagementError.unauthenticated
        }
        
        let startTime = Date()
        
        do {
            try await manager.cardService.activateCard(cardID: id, sessionToken: sessionToken)
            
            let event = LogEvent.stateManagement(cardId: id,
                                                 originalState: state,
                                                 requestedState: .active,
                                                 reason: nil)
            manager.logger?.log(event, startedAt: startTime)
            state = .active
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Activate Card",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id, "originalState": state, "newState": CardState.active, "reason": ""]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        }
    }

    /// Suspends the card, temporarily disabling it for transactions.
    ///
    /// This method transitions the card to a suspended state, preventing the cardholder from using it
    /// for purchases or other transactions. The card can be reactivated later. A suspension reason can
    /// optionally be provided for audit purposes. The card must be in a state that permits suspension
    /// (check ``possibleStateChanges`` for valid transitions).
    ///
    /// **Important:** This method requires an active session. You must call ``CheckoutCardManager/logInSession(token:)``
    /// with a valid session token before invoking this method.
    ///
    /// - Parameters:
    ///     - reason: An optional reason for suspending the card (e.g., lost, stolen, suspected fraud).
    ///     - completionHandler: A closure called with the result indicating either success or failure with a ``CardManagementError``.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version ``suspend(reason:)``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/invalidStateRequested`` if the card cannot be suspended from its current state
    /// - ``CardManagementError/unauthenticated`` if no session is active
    /// - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.suspend(reason: .lost) { result in
    ///     switch result {
    ///     case .success:
    ///         print("Card suspended successfully")
    ///     case .failure(let error):
    ///         print("Failed to suspend card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``CardSuspendReason``, ``activate(completionHandler:)``, ``revoke(reason:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "suspend(reason:)")
    func suspend(reason: CardSuspendReason?,
                 completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await suspend(reason: reason)
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Suspends the card, temporarily disabling it for transactions.
    ///
    /// This method transitions the card to a suspended state, preventing the cardholder from using it
    /// for purchases or other transactions. The card can be reactivated later. A suspension reason can
    /// optionally be provided for audit purposes. The card must be in a state that permits suspension
    /// (check ``possibleStateChanges`` for valid transitions).
    ///
    /// **Important:** This method requires an active session. You must call ``CheckoutCardManager/logInSession(token:)``
    /// with a valid session token before invoking this method.
    ///
    /// - Parameters:
    ///     - reason: An optional reason for suspending the card (e.g., lost, stolen, suspected fraud).
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/invalidStateRequested`` if the card cannot be suspended from its current state
    ///   - ``CardManagementError/unauthenticated`` if no session is active
    ///   - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         try await card.suspend(reason: .lost)
    ///         print("Card suspended successfully")
    ///     } catch {
    ///         print("Failed to suspend card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``CardSuspendReason``, ``activate()``, ``revoke(reason:)``
    /// - Since: 4.0.0
    func suspend(reason: CardSuspendReason?) async throws {
        guard possibleStateChanges.contains(.suspended) else {
            throw CardManagementError.invalidStateRequested
        }
        guard let manager = manager, let sessionToken = manager.sessionToken else {
            throw CardManagementError.unauthenticated
        }
        
        let startTime = Date()
        
        do {
            try await manager.cardService.suspendCard(cardID: id, reason: reason, sessionToken: sessionToken)
            
            let event = LogEvent.stateManagement(cardId: id,
                                                 originalState: state,
                                                 requestedState: .suspended,
                                                 reason: reason?.rawValue)
            manager.logger?.log(event, startedAt: startTime)
            state = .suspended
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Suspend Card",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id, "originalState": state, "newState": CardState.suspended, "reason": reason?.rawValue ?? ""]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        }
    }

    /// Revokes the card, permanently disabling it for transactions.
    ///
    /// This method transitions the card to a revoked state, permanently preventing the cardholder from
    /// using it for any transactions. This action is irreversible - a revoked card cannot be reactivated.
    /// A revocation reason can optionally be provided for audit purposes. The card must be in a state
    /// that permits revocation (check ``possibleStateChanges`` for valid transitions).
    ///
    /// **Important:** This method requires an active session. You must call ``CheckoutCardManager/logInSession(token:)``
    /// with a valid session token before invoking this method.
    ///
    /// **Warning:** Revoking a card is a permanent action and cannot be undone.
    ///
    /// - Parameters:
    ///     - reason: An optional reason for revoking the card (e.g., stolen, compromised, closed by cardholder).
    ///     - completionHandler: A closure called with the result indicating either success or failure with a ``CardManagementError``.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version ``revoke(reason:)``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/invalidStateRequested`` if the card cannot be revoked from its current state
    /// - ``CardManagementError/unauthenticated`` if no session is active
    /// - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.revoke(reason: .stolen) { result in
    ///     switch result {
    ///     case .success:
    ///         print("Card revoked successfully")
    ///     case .failure(let error):
    ///         print("Failed to revoke card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``CardRevokeReason``, ``activate(completionHandler:)``, ``suspend(reason:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "revoke(reason:)")
    func revoke(reason: CardRevokeReason?,
                completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await revoke(reason: reason)
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Revokes the card, permanently disabling it for transactions.
    ///
    /// This method transitions the card to a revoked state, permanently preventing the cardholder from
    /// using it for any transactions. This action is irreversible - a revoked card cannot be reactivated.
    /// A revocation reason can optionally be provided for audit purposes. The card must be in a state
    /// that permits revocation (check ``possibleStateChanges`` for valid transitions).
    ///
    /// **Important:** This method requires an active session. You must call ``CheckoutCardManager/logInSession(token:)``
    /// with a valid session token before invoking this method.
    ///
    /// **Warning:** Revoking a card is a permanent action and cannot be undone.
    ///
    /// - Parameters:
    ///     - reason: An optional reason for revoking the card (e.g., stolen, compromised, closed by cardholder).
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/invalidStateRequested`` if the card cannot be revoked from its current state
    ///   - ``CardManagementError/unauthenticated`` if no session is active
    ///   - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         try await card.revoke(reason: .stolen)
    ///         print("Card revoked successfully")
    ///     } catch {
    ///         print("Failed to revoke card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``CardRevokeReason``, ``activate()``, ``suspend(reason:)``
    /// - Since: 4.0.0
    func revoke(reason: CardRevokeReason?) async throws {
        guard possibleStateChanges.contains(.revoked) else {
            throw CardManagementError.invalidStateRequested
        }
        guard let manager = manager, let sessionToken = manager.sessionToken else {
            throw CardManagementError.unauthenticated
        }
        
        let startTime = Date()
        
        do {
            try await manager.cardService.revokeCard(cardID: id, reason: reason, sessionToken: sessionToken)
            
            let event = LogEvent.stateManagement(cardId: id,
                                                 originalState: state,
                                                 requestedState: .revoked,
                                                 reason: reason?.rawValue)
            manager.logger?.log(event, startedAt: startTime)
            state = .revoked
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Revoke Card",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id, "originalState": state, "newState": CardState.revoked, "reason": reason?.rawValue ?? ""]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        }
    }
}
