//
//  Card+SecurityCode.swift
//  
//
//  Created by Alex Ioja-Yang on 02/11/2022.
//

import Foundation
import UIKit
import CheckoutCardNetworkStub

public extension Card {

    /// Retrieves a secure UI component displaying the card's security code
    ///
    /// This method returns a protected UIView containing the card's security code.. The security code is sensitive
    /// cardholder data and should be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for security code retrieval and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the security code retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///     - completionHandler: A closure called with the result containing either a secure `UIView` or a `CardManagementError`.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version `getSecurityCode(singleUseToken:)`
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
    /// card.getSecurityCode(singleUseToken: token) { result in
    ///     switch result {
    ///     case .success(let securityCodeView):
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(securityCodeView)
    ///     case .failure(let error):
    ///         print("Failed to get security code: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPanAndSecurityCode(singleUseToken:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "getSecurityCode(singleUseToken:)")
    func getSecurityCode(singleUseToken: String,
                         completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let securityCodeView = try await getSecurityCode(singleUseToken: singleUseToken)
                completionHandler(.success(securityCodeView))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Retrieves a secure UI component displaying the card's security code
    ///
    /// This method returns a protected UIView containing the card's security code.. The security code is sensitive
    /// cardholder data and should be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for security code retrieval and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the security code retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///
    /// - Returns: A secure `UIView` containing the card's security code. This view should be added to your UI hierarchy
    ///           and will render the security code securely.
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
    ///         let securityCodeView = try await card.getSecurityCode(singleUseToken: token)
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(securityCodeView)
    ///     } catch {
    ///         print("Failed to get security code: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPanAndSecurityCode(singleUseToken:)``
    /// - Since: 4.0.0
    func getSecurityCode(singleUseToken: String) async throws -> UIView {
        guard let manager = manager else {
            throw CardManagementError.missingManager
        }
        
        let securityCodeViewDesign = manager.designSystem.securityCodeViewDesign
        let startTime = Date()
        
        do {
            let securityCodeView = try await manager.cardService.displaySecurityCode(
                forCard: id,
                displayConfiguration: securityCodeViewDesign,
                singleUseToken: singleUseToken
            )
            
            let event = LogEvent.getCVV(cardId: id, cardState: state)
            manager.logger?.log(event, startedAt: startTime)
            
            return securityCodeView
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Get Security Code",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        } catch {
            manager.logger?.log(
                .failure(source: "Get Security Code",
                         error: error,
                         networkError: nil,
                         additionalInfo: ["cardId": id, "errorMessage": error.localizedDescription]),
                startedAt: startTime
            )
            
            throw CardManagementError.connectionIssue
        }
    }
}
