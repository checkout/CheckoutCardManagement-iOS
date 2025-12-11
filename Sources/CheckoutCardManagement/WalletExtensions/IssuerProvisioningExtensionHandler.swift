//
//  IntentHandler.swift
//  WalletExtension
//
//  Created by Marian Enache on 14.02.2025.
//

import CheckoutCardNetwork
import CheckoutEventLoggerKit

/// Base handler class for the Issuer Provisioning Extension.
///
/// `IssuerProvisioningExtensionHandler` provides the foundation for handling Apple Wallet
/// provisioning requests initiated directly from the Wallet app. This handler must be subclassed
/// and set as the principal class for your Issuer Provisioning Extension target.
///
/// The Issuer Provisioning Extension allows users to add cards to Apple Wallet directly from
/// the Wallet app, rather than through your main application. This requires a separate extension
/// target in your project.
///
/// **Important:** You must subclass this handler and override the ``onError(_ error: CardManagementError.ProvisioningExtensionFailure)`` method to
/// handle provisioning errors appropriately for your application.
///
/// ## Integration
///
/// 1. Create a new Issuer Provisioning Extension target in your Xcode project
/// 2. Create a subclass of `IssuerProvisioningExtensionHandler`
/// 3. Set your subclass as the principal class in the extension's `Info.plist`
/// 4. Override ``onError(_ error: CardManagementError.ProvisioningExtensionFailure)`` to handle provisioning failures
///
/// ## Example
///
/// ```swift
/// import CheckoutCardManagement
///
/// class MyProvisioningHandler: IssuerProvisioningExtensionHandler {
///
///     override func onError(_ error: CardManagementError.ProvisioningExtensionFailure) {
///         // Log or handle the error
///         switch error {
///         case .cardNotFound:
///             print("Card not found for provisioning")
///         case .deviceEnvironmentUnsafe:
///             print("Device is jailbroken - provisioning blocked")
///         case .walletExtensionAppGroupIDNotFound:
///             print("App Group not configured")
///         case .operationFailure:
///             print("Provisioning operation failed")
///         }
///     }
/// }
/// ```
///
/// - Note: This class is only available on iOS 14.0 and later, as required by Apple's
///   Issuer Provisioning Extension framework.
///
/// - SeeAlso: ``IssuerProvisioningExtensionAuthorizationProviding``, 
///   ``CardManagementError/ProvisioningExtensionFailure``,
///   ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``
@available(iOS 14.0, *)
open class IssuerProvisioningExtensionHandler: CKOIssuerProvisioningExtensionHandler {

    /// Initializes the handler with built-in logging support.
    public override init() {
        super.init()
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)
        initLogger(logger: logger)
    }

    final public override func onError(_ error: CardNetworkError.ProvisioningExtensionFailure) {
        onError(.from(error))
    }

    /// Called when a provisioning error occurs in the Wallet Extension.
    ///
    /// Override this method in your subclass to handle provisioning failures. This is where
    /// you should implement error logging, analytics tracking, or any custom error handling
    /// logic specific to your application.
    ///
    /// This method is called on the main thread.
    ///
    /// - Parameter error: The specific provisioning extension failure that occurred.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onError(_ error: CardManagementError.ProvisioningExtensionFailure) {
    ///     analytics.track(event: "provisioning_failed", properties: ["error": "\(error)"])
    ///     
    ///     switch error {
    ///     case .cardNotFound:
    ///         logger.error("Card not available for provisioning")
    ///     case .deviceEnvironmentUnsafe:
    ///         logger.warning("Provisioning blocked on jailbroken device")
    ///     case .walletExtensionAppGroupIDNotFound:
    ///         logger.error("App Group configuration missing")
    ///     case .operationFailure:
    ///         logger.error("General provisioning failure")
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``CardManagementError/ProvisioningExtensionFailure``
    open func onError(_ error: CardManagementError.ProvisioningExtensionFailure) {

    }
}
