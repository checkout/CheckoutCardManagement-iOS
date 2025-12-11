//
//  Card+Pan.swift
//
//
//  Created by Alex Ioja-Yang on 16/06/2022.
//

import Foundation
import UIKit
import CheckoutCardNetworkStub

public extension Card {

    /// Retrieves a secure UI component displaying the card's Primary Account Number (PAN).
    ///
    /// This method returns a protected UIView containing the full card number (PAN). The view is
    /// rendered securely by the underlying card service to prevent unauthorized access or screen capture.
    /// The PAN is sensitive cardholder data and should be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PAN retrieval and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the PAN retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///     - completionHandler: A closure called with the result containing either a secure `UIView` or a `CardManagementError`.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version `getPan(singleUseToken:)`
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
    /// card.getPan(singleUseToken: token) { result in
    ///     switch result {
    ///     case .success(let panView):
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(panView)
    ///     case .failure(let error):
    ///         print("Failed to get PAN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPanAndSecurityCode(singleUseToken:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "getPan(singleUseToken:)")
    func getPan(singleUseToken: String,
                completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let panView = try await getPan(singleUseToken: singleUseToken)
                completionHandler(.success(panView))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Retrieves a secure UI component displaying the card's Primary Account Number (PAN).
    ///
    /// This async method returns a protected UIView containing the full card number (PAN). The view is
    /// rendered securely by the underlying card service to prevent unauthorized access or screen capture.
    /// The PAN is sensitive cardholder data and should be handled according to PCI-DSS requirements.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PAN retrieval and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize the PAN retrieval operation.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///
    /// - Returns: A secure `UIView` containing the card's PAN. This view should be added to your UI hierarchy
    ///           and will render the PAN securely.
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
    ///         let panView = try await card.getPan(singleUseToken: token)
    ///         // Add the secure view to your UI
    ///         containerView.addSubview(panView)
    ///     } catch {
    ///         print("Failed to get PAN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPanAndSecurityCode(singleUseToken:)``
    /// - Since: 4.0.0
    func getPan(singleUseToken: String) async throws -> UIView {
        guard let manager = manager else {
            throw CardManagementError.missingManager
        }
        
        let panViewDesign = manager.designSystem.panViewDesign
        let startTime = Date()
        
        do {
            let panView = try await manager.cardService.displayPan(
                forCard: id,
                displayConfiguration: panViewDesign,
                singleUseToken: singleUseToken
            )
            
            let event = LogEvent.getPan(cardId: id, cardState: state)
            manager.logger?.log(event, startedAt: startTime)
            
            return panView
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Get Pan",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        } catch {
            manager.logger?.log(
                .failure(source: "Get Pan",
                         error: error,
                         networkError: nil,
                         additionalInfo: ["cardId": id, "errorMessage": error.localizedDescription]),
                startedAt: startTime
            )
            
            throw CardManagementError.connectionIssue
        }
    }

    /// Copies the card's Primary Account Number (PAN) to the device clipboard.
    ///
    /// This method securely retrieves the card's PAN and copies it to the system clipboard. The PAN
    /// is sensitive cardholder data and should be handled according to PCI-DSS requirements. Once copied,
    /// users can paste the PAN into other applications.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PAN retrieval and can only be used once.
    ///
    /// **Security Note:** The copied PAN will remain in the clipboard until overwritten. Consider
    /// implementing clipboard clearing after a timeout for enhanced security.
    ///
    /// - Parameters:
    ///   - singleUseToken: A short-lived, single-use token required to authorize the PAN copy operation.
    ///                    This token must be obtained from your backend and is valid for one use only.
    ///   - completionHandler: A closure executed upon completion. It receives a `CardDetailCopyResult`
    ///                      indicating either success or the reason for failure.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version `copyPan(singleUseToken:)`
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/unableToCopy(failure:)`` with `missingManager` if the CardManager was deallocated
    /// - ``CardManagementError/authenticationFailure`` if the single-use token has expired or is invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    /// - ``CardManagementError/unableToCopy(failure:)`` with `copyFailure` if clipboard operation fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.copyPan(singleUseToken: token) { result in
    ///     switch result {
    ///     case .success:
    ///         print("PAN copied to clipboard")
    ///         // Optionally show a success message to the user
    ///     case .failure(let error):
    ///         print("Failed to copy PAN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPan(singleUseToken:completionHandler:)``
    /// - Since: 3.1.0
    @available(*, deprecated, renamed: "copyPan(singleUseToken:)")
    func copyPan(singleUseToken: String,
                 completionHandler: @escaping ((CheckoutCardManager.CardDetailCopyResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await copyPan(singleUseToken: singleUseToken)
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Copies the card's Primary Account Number (PAN) to the device clipboard.
    ///
    /// This async method securely retrieves the card's PAN and copies it to the system clipboard. The PAN
    /// is sensitive cardholder data and should be handled according to PCI-DSS requirements. Once copied,
    /// users can paste the PAN into other applications.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for PAN retrieval and can only be used once.
    ///
    /// **Security Note:** The copied PAN will remain in the clipboard until overwritten. Consider
    /// implementing clipboard clearing after a timeout for enhanced security.
    ///
    /// - Parameters:
    ///   - singleUseToken: A short-lived, single-use token required to authorize the PAN copy operation.
    ///                    This token must be obtained from your backend and is valid for one use only.
    ///
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/unableToCopy(failure:)`` with `missingManager` if the CardManager was deallocated
    ///   - ``CardManagementError/authenticationFailure`` if the single-use token has expired or is invalid
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///   - ``CardManagementError/unableToCopy(failure:)`` with `copyFailure` if clipboard operation fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// Task {
    ///     do {
    ///         try await card.copyPan(singleUseToken: token)
    ///         print("PAN copied to clipboard")
    ///         // Optionally show a success message to the user
    ///     } catch {
    ///         print("Failed to copy PAN: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPan(singleUseToken:)``
    /// - Since: 4.0.0
    func copyPan(singleUseToken: String) async throws {
        guard let manager = manager else {
            throw CardManagementError.unableToCopy(failure: .missingManager)
        }

        let startTime = Date()
        
        do {
            try await manager.cardService.copyPan(forCard: id, singleUseToken: singleUseToken)
            
            let logEvent = LogEvent.copyPan(cardId: id, cardState: state)
            manager.logger?.log(logEvent, startedAt: startTime)
        } catch let error as CardNetworkError {
            let logEvent = LogEvent.failure(
                source: "Copy Pan",
                error: error,
                networkError: error,
                additionalInfo: ["cardId": id]
            )
            manager.logger?.log(logEvent, startedAt: startTime)
            throw CardManagementError.from(error)
        } catch {
            let logEvent = LogEvent.failure(
                source: "Copy Pan",
                error: error,
                networkError: nil,
                additionalInfo: ["cardId": id, "errorMessage": error.localizedDescription]
            )
            manager.logger?.log(logEvent, startedAt: startTime)
            
            throw CardManagementError.connectionIssue
        }
    }

    /// Retrieves secure UI components for both the card's PAN and security code (CVV).
    ///
    /// This method returns a tuple of protected UIViews containing both the full card number (PAN) and
    /// the security code (CVV/CVC). Both views are rendered securely to prevent unauthorized access or
    /// screen capture. This is more efficient than making separate calls to `getPan` and `getSecurityCode`,
    /// as it uses a single token for both operations.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for retrieving both PAN and security code, and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize retrieval of both card details.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///     - completionHandler: A closure called with the result containing either a tuple of secure UIViews
    ///                         (pan and securityCode) or a `CardManagementError`.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version `getPanAndSecurityCode(singleUseToken:)`
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
    /// card.getPanAndSecurityCode(singleUseToken: token) { result in
    ///     switch result {
    ///     case .success(let (panView, securityCodeView)):
    ///         // Add both secure views to your UI
    ///         panContainer.addSubview(panView)
    ///         cvvContainer.addSubview(securityCodeView)
    ///     case .failure(let error):
    ///         print("Failed to get card details: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPan(singleUseToken:completionHandler:)``, ``getSecurityCode(singleUseToken:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "getPanAndSecurityCode(singleUseToken:)")
    func getPanAndSecurityCode(singleUseToken: String,
                               completionHandler: @escaping CheckoutCardManager.SecurePropertiesResultCompletion) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let views = try await getPanAndSecurityCode(singleUseToken: singleUseToken)
                completionHandler(.success(views))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }

    /// Retrieves secure UI components for both the card's PAN and security code (CVV).
    ///
    /// This async method returns a tuple of protected UIViews containing both the full card number (PAN) and
    /// the security code (CVV/CVC). Both views are rendered securely to prevent unauthorized access or
    /// screen capture. This is more efficient than making separate calls to `getPan` and `getSecurityCode`,
    /// as it uses a single token for both operations.
    ///
    /// **Important:** This method requires a single-use token obtained from your backend service.
    /// The token must be generated specifically for retrieving both PAN and security code, and can only be used once.
    ///
    /// - Parameters:
    ///     - singleUseToken: A short-lived, single-use token required to authorize retrieval of both card details.
    ///                      This token must be obtained from your backend and is valid for one use only.
    ///
    /// - Returns: A tuple containing two secure UIViews: `pan` (containing the card number) and `securityCode`
    ///           (containing the CVV/CVC). Both views should be added to your UI hierarchy and will render securely.
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
    ///         let (panView, securityCodeView) = try await card.getPanAndSecurityCode(singleUseToken: token)
    ///         // Add both secure views to your UI
    ///         panContainer.addSubview(panView)
    ///         cvvContainer.addSubview(securityCodeView)
    ///     } catch {
    ///         print("Failed to get card details: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CheckoutCardManager``, ``getPan(singleUseToken:)``, ``getSecurityCode(singleUseToken:)``
    /// - Since: 4.0.0
    func getPanAndSecurityCode(singleUseToken: String) async throws -> (pan: UIView, securityCode: UIView) {
        guard let manager = manager else {
            throw CardManagementError.missingManager
        }
        
        let panViewDesign = manager.designSystem.panViewDesign
        let securityCodeDesign = manager.designSystem.securityCodeViewDesign
        let startTime = Date()
        
        do {
            let views = try await manager.cardService.displayPanAndSecurityCode(
                forCard: id,
                panViewConfiguration: panViewDesign,
                securityCodeViewConfiguration: securityCodeDesign,
                singleUseToken: singleUseToken
            )
            
            let event = LogEvent.getPanCVV(cardId: id, cardState: state)
            manager.logger?.log(event, startedAt: startTime)
            
            return views
        } catch let error as CardNetworkError {
            manager.logger?.log(
                .failure(source: "Get Pan and SecurityCode",
                         error: error,
                         networkError: error,
                         additionalInfo: ["cardId": id]),
                startedAt: startTime
            )
            throw CardManagementError.from(error)
        } catch {
            manager.logger?.log(
                .failure(source: "Get Pan and SecurityCode",
                         error: error,
                         networkError: nil,
                         additionalInfo: ["cardId": id, "errorMessage": error.localizedDescription]),
                startedAt: startTime
            )
            
            throw CardManagementError.connectionIssue
        }
    }
}
