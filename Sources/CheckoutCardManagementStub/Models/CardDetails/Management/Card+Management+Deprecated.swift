//
//  Card+Management+Deprecated.swift
//  CheckoutCardManagement
//
//  Created by Tinashe Makuti on 06/11/2025.
//

import UIKit
import CheckoutCardNetworkStub

public extension Card {
    /// Retrieves the digitization state of the card for Apple Pay provisioning.
    ///
    /// This method checks whether the card has been added to Apple Wallet and retrieves its
    /// current digitization status. This is useful for determining if a card is already provisioned
    /// before attempting to add it to Apple Wallet.
    ///
    /// - Parameters:
    ///     - provisioningToken: The provisioning token required to authenticate the digitization state request
    ///     - completionHandler: A closure called with the result containing either ``DigitizationData`` on success
    ///                         or a ``CardManagementError`` on failure. The completion handler is called on the main thread.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version ``getDigitizationState(provisioningToken:)``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/fetchDigitizationStateFailure(failure:)`` if the request fails
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.getDigitizationState(provisioningToken: token) { result in
    ///     switch result {
    ///     case .success(let digitizationData):
    ///         print("Digitization state: \(digitizationData.state)")
    ///     case .failure(let error):
    ///         print("Failed to fetch digitization state: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``DigitizationData``, ``provision(provisioningToken:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "getDigitizationState(provisioningToken:)")
    func getDigitizationState(provisioningToken: String,
                              completionHandler: @escaping ((CheckoutCardManager.CardDigitizationResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let digitizationData = try await getDigitizationState(provisioningToken: provisioningToken)
                completionHandler(.success(digitizationData))
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            } catch {
                completionHandler(.failure(.fetchDigitizationStateFailure(failure: .operationFailure)))
            }
        }
    }


    /// Provisions the card to Apple Wallet for contactless payments.
    ///
    /// This method adds the card to Apple Wallet on the device, allowing the cardholder to make
    /// contactless payments using Apple Pay. The method automatically finds the active view controller
    /// to present the Apple Pay provisioning UI.
    ///
    /// **Important:** This method must be called when a view controller is available and active.
    /// The provisioning process will display Apple's standard card addition flow.
    ///
    /// - Parameters:
    ///     - provisioningToken: The provisioning token required to authenticate and provision the card to Apple Wallet
    ///     - completionHandler: A closure called with the result indicating either success or failure with a ``CardManagementError``.
    ///                         The completion handler is called on the main thread.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version
    ///         ``provision(provisioningToken:viewController:)``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/pushProvisioningFailure(failure:)`` if the provisioning request fails or no active view controller is found
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    /// - ``CardManagementError/authenticationFailure`` if the provisioning token is invalid or expired
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.provision(provisioningToken: token) { result in
    ///     switch result {
    ///     case .success:
    ///         print("Card successfully added to Apple Wallet")
    ///     case .failure(let error):
    ///         print("Failed to provision card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``getDigitizationState(provisioningToken:completionHandler:)``, ``provision(provisioningToken:viewController:)``
    /// - Since: 1.0.0
    // coverage: ignore
    @available(*, deprecated, renamed: "provision(provisioningToken:viewController:)")
    func provision(provisioningToken: String,
                   completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            completionHandler(.failure(CardManagementError.pushProvisioningFailure(failure: .configurationFailure)))
            return
        }

        guard let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = keyWindow.rootViewController else {
            completionHandler(.failure(CardManagementError.pushProvisioningFailure(failure: .configurationFailure)))
            return
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await provision(provisioningToken: provisioningToken, viewController: rootViewController)
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            } catch {
                completionHandler(.failure(.pushProvisioningFailure(failure: .operationFailure)))
            }
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
    /// - Parameters:
    ///     - completionHandler: A closure called with the result indicating either success or failure with a ``CardManagementError``.
    ///
    /// - Note: This is the callback-based version. For Swift concurrency support, use the async version ``activate()``
    ///
    /// The completion handler receives a result which may contain the following errors:
    /// - ``CardManagementError/invalidStateRequested`` if the card cannot be activated from its current state
    /// - ``CardManagementError/unauthenticated`` if no session is active
    /// - ``CardManagementError/authenticationFailure`` if the session token has expired or is invalid
    /// - ``CardManagementError/connectionIssue`` if there are network connectivity problems
    ///
    /// ## Example
    ///
    /// ```swift
    /// card.activate { result in
    ///     switch result {
    ///     case .success:
    ///         print("Card activated successfully")
    ///     case .failure(let error):
    ///         print("Failed to activate card: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``possibleStateChanges``, ``CardState``, ``suspend(reason:completionHandler:)``, ``revoke(reason:completionHandler:)``
    /// - Since: 1.0.0
    @available(*, deprecated, renamed: "activate()")
    func activate(completionHandler: @escaping ((CheckoutCardManager.OperationResult) -> Void)) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await activate()
                completionHandler(.success)
            } catch let error as CardManagementError {
                completionHandler(.failure(error))
            }
        }
    }
}
