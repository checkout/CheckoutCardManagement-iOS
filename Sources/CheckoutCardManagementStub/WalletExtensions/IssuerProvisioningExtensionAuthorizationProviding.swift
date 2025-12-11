//
//  IntentHandler.swift
//  WalletExtension
//
//  Created by Marian Enache on 14.02.2025.
//

import CheckoutCardNetworkStub
import CheckoutEventLoggerKit

/// Protocol for providing authorization in the Issuer Provisioning Extension.
///
/// `IssuerProvisioningExtensionAuthorizationProviding` defines the interface for authenticating
/// provisioning requests initiated from the Apple Wallet app. Types conforming to this protocol
/// can authenticate the provisioning session using an issuer token.
///
/// This protocol is typically adopted by your Issuer Provisioning Extension's principal class
/// or a dedicated authorization manager within the extension target.
///
/// **Important:** This protocol is part of the Wallet Extension flow and should only be used
/// within your Issuer Provisioning Extension target, not in the main application.
///
/// ## Integration
///
/// Conform to this protocol in your extension's principal class or authorization handler:
///
/// ```swift
/// import CheckoutCardManagement
///
/// class MyAuthorizationProvider: NSObject, IssuerProvisioningExtensionAuthorizationProviding {
///
///     func authenticateForProvisioning(issuerToken: String) {
///         login(issuerToken) { error in
///             if let error = error {
///                 print("Authentication failed: \(error)")
///             } else {
///                 print("Authentication successful")
///             }
///         }
///     }
/// }
/// ```
///
/// - Note: This protocol is only available on iOS 14.0 and later, matching Apple's
///   Issuer Provisioning Extension requirements.
///
/// - SeeAlso: ``IssuerProvisioningExtensionHandler``, 
///   ``CardManagementError/ProvisioningExtensionFailure``,
///   ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``
@available(iOS 14.0, *)
public protocol IssuerProvisioningExtensionAuthorizationProviding: CKOIssuerProvisioningExtensionAuthorizationProviding {
}

@available(iOS 14.0, *)
extension IssuerProvisioningExtensionAuthorizationProviding {

    /// Authenticates the provisioning session with an issuer token.
    ///
    /// This method authenticates the user's provisioning request using the provided issuer token.
    /// Call this method when your Wallet Extension needs to authenticate before allowing card
    /// provisioning to proceed.
    ///
    /// The method performs the authentication asynchronously and calls the completion handler
    /// with the result. On success, the completion handler receives `nil`. On failure, it receives
    /// a specific ``CardManagementError/ProvisioningExtensionFailure`` indicating the problem.
    ///
    /// - Parameters:
    ///   - issuerToken: The authentication token provided by your backend or token service.
    ///                  This token identifies and authorizes the provisioning session.
    ///   - completion: A closure called when authentication completes. Receives `nil` on success,
    ///                or a ``CardManagementError/ProvisioningExtensionFailure`` on failure.
    ///                The completion handler is called on the main thread.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class MyExtensionProvider: NSObject, IssuerProvisioningExtensionAuthorizationProviding {
    ///
    ///     func authenticate(with token: String) {
    ///         login(token) { error in
    ///             if let error = error {
    ///                 switch error {
    ///                 case .walletExtensionAppGroupIDNotFound:
    ///                     print("App Group not configured")
    ///                 case .cardNotFound:
    ///                     print("Card not available")
    ///                 case .deviceEnvironmentUnsafe:
    ///                     print("Device is compromised")
    ///                 case .operationFailure:
    ///                     print("Authentication failed")
    ///                 }
    ///             } else {
    ///                 // Proceed with provisioning
    ///                 print("Authentication successful")
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CardManagementError/ProvisioningExtensionFailure``
    public func login(_ issuerToken: String, completion: @escaping (CardManagementError.ProvisioningExtensionFailure?) -> Void) {
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)

        login(token: issuerToken, logger: logger) { (error: CardNetworkError.ProvisioningExtensionFailure?) in
            if error != nil {
                completion(.from(error!))
            } else {
                completion(nil)
            }
        }
    }
}
