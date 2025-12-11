//
//  Card+Pin.swift
//  
//
//  Created by Alex Ioja-Yang on 15/06/2022.
//

import Foundation
import UIKit
import CheckoutCardNetworkStub

public extension Card {

    /// Retrieves a secure UI component displaying the card's Personal Identification Number (PIN).
    ///
    /// This method returns a protected UIView containing the card's PIN. The view is rendered
    /// securely by the underlying card service to prevent unauthorized access or screen capture.
    /// The PIN is highly sensitive cardholder data and must be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PIN retrieval and can only be used once.
    ///
    /// **Security Note:** PIN display should be time-limited and only shown when absolutely necessary
    /// for cardholder verification purposes.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the PIN retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///     - completionHandler: A closure called with the result containing either a secure `UIView` or a `CardManagementError`.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version `getPin(singleUseToken:)`
    ///
    /// The completion handler receives a `Result` which may contain the following errors:
    /// - ``CardManagementError/missingManager`` if the CardManager was deallocated
    /// - ``CardManagementError/authenticationFailure`` if the single-use token has expired or is invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    /// - ``CardManagementError/unableToPerformSecureOperation`` if secure rendering fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.getPin(singleUseToken: token) { result in
    ///     switch result {
    ///     case .success(let pinView):
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(pinView)
    ///         // Consider auto-hiding after a timeout for security
    ///     case .failure(let error):
    ///         print("Failed to get PIN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "getPin(singleUseToken:)")
    func getPin(singleUseToken: String,
                completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let pinView = try await getPin(singleUseToken: singleUseToken)
                completionHandler(.success(pinView))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Retrieves a secure UI component displaying the card's Personal Identification Number (PIN).
    ///
    /// This async method returns a protected UIView containing the card's PIN. The view is rendered
    /// securely by the underlying card service to prevent unauthorized access or screen capture.
    /// The PIN is highly sensitive cardholder data and must be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PIN retrieval and can only be used once.
    ///
    /// **Security Note:** PIN display should be time-limited and only shown when absolutely necessary
    /// for cardholder verification purposes.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the PIN retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///
    /// - Returns: A secure `UIView` containing the card's PIN. This view should be added to your UI hierarchy
    ///           and will render the PIN securely. Consider implementing auto-hide functionality for enhanced security.
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/missingManager`` if the CardManager was deallocated
    ///   - ``CardManagementError/authenticationFailure`` if the single-use token has expired or is invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///   - ``CardManagementError/unableToPerformSecureOperation`` if secure rendering fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         let pinView = try await card.getPin(singleUseToken: token)
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(pinView)
    ///         // Consider auto-hiding after a timeout for security
    ///     } catch {
    ///         print("Failed to get PIN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``
    /// - Since: 4.0.0
    func getPin(singleUseToken: String) async throws -> UIView {
        guard let manager = manager else {
            throw CardManagementError.missingManager
        }
        
        let pinViewDesign = manager.designSystem.pinViewDesign
        let startTime = Date()
        
        do {
            let pinView = try await manager.cardService.displayPin(
                forCard: id,
                displayConfiguration: pinViewDesign,
                singleUseToken: singleUseToken
            )
            
            let event = LogEvent.getPin(cardId: id, cardState: state)
            manager.logger?.log(event, startedAt: startTime)
            
            return pinView
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Get Pin",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        } catch {
            manager.logger?.log(
                .failure(source: "Get Pin",
                         error: error,
                         networkError: nil,
                         additionalInfo: ["cardId": id, "errorMessage": error.localizedDescription]),
                startedAt: startTime
            )
            
            throw CardManagementError.connectionIssue
        }
    }
}
