//
//  CardManagementError.swift
//
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation
import CheckoutCardNetwork

/// Comprehensive error types for all card management operations.
///
/// `CardManagementError` provides a complete set of error cases that can occur during card management
/// operations. These errors are returned in `Result` types from callback-based methods and thrown from
/// async methods throughout the SDK.
///
/// The error type is organized into top-level cases for common failures and nested enums for
/// specialized operation failures:
/// - ``PushProvisioningFailure`` - Errors specific to Apple Wallet provisioning
/// - ``ProvisioningExtensionFailure`` - Errors from Wallet Extension operations
/// - ``DigitizationStateFailure`` - Errors when querying card digitization state
/// - ``CopySensitiveDataError`` - Errors when copying sensitive card data
///
/// ## Usage
///
/// ```swift
/// // With async/await
/// do {
///     let cards = try await cardManager.getCards()
/// } catch CardManagementError.unauthenticated {
///     // Prompt user to log in
/// } catch CardManagementError.connectionIssue {
///     // Show network error
/// } catch {
///     // Handle other errors
/// }
///
/// // With completion handlers
/// cardManager.getCards { result in
///     switch result {
///     case .success(let cards):
///         // Use cards
///     case .failure(let error):
///         handleError(error)
///     }
/// }
/// ```
///
/// - SeeAlso: ``CheckoutCardManager``, ``Card``
public enum CardManagementError: Error, Equatable {

    /// Errors specific to Apple Wallet push provisioning operations.
    ///
    /// These errors occur during the process of adding a card to Apple Wallet.
    /// They provide specific failure reasons to help with error handling and user feedback.
    ///
    /// - SeeAlso: ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``
    public enum PushProvisioningFailure: Error, Equatable {
        /// The user cancelled the Apple Wallet provisioning flow.
        ///
        /// This occurs when the user explicitly dismisses or cancels the provisioning
        /// process in the system UI. No retry is needed unless the user initiates again.
        case cancelled

        /// The push provisioning configuration was invalid or rejected.
        ///
        /// This indicates a problem with the configuration parameters provided to
        /// ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``.
        /// Review the configuration parameters and ensure they meet requirements.
        case configurationFailure

        /// The provisioning operation failed during execution.
        ///
        /// A general failure occurred during the provisioning flow. This may be due to
        /// network issues, server problems, or other runtime errors. Retry may be appropriate.
        case operationFailure

        static func from(_ networkError: CardNetworkError.PushProvisioningFailure) -> Self {
            switch networkError {
            case .cancelled: return .cancelled
            case .configurationFailure: return .configurationFailure
            case .operationFailure: return .operationFailure
            }
        }
    }

    /// Errors specific to Wallet Extension provisioning operations.
    ///
    /// These errors occur during card provisioning initiated from the Wallet app itself,
    /// handled by the Issuer Provisioning Extension. They indicate failures in the extension's
    /// authorization and provisioning flow.
    ///
    /// - SeeAlso: ``IssuerProvisioningExtensionHandler``, ``IssuerProvisioningExtensionAuthorizationProviding``
    public enum ProvisioningExtensionFailure: Error, Equatable {
        /// The App Group identifier required for Wallet Extension was not found.
        ///
        /// The App Group ID is required for sharing data between the main app and the
        /// Wallet Extension. Ensure you have configured an App Group and provided it during
        /// push provisioning configuration.
        ///
        /// **Recovery:** Configure the App Group in your project and provide the correct
        /// identifier to ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``.
        case walletExtensionAppGroupIDNotFound

        /// The requested card could not be found or is invalid.
        ///
        /// This occurs when the Wallet Extension attempts to provision a card that doesn't
        /// exist or is not available for the current cardholder.
        ///
        /// **Recovery:** Verify the card ID and ensure the card is available for provisioning.
        case cardNotFound

        /// The device environment has been compromised (jailbroken/rooted).
        ///
        /// For security reasons, card provisioning is blocked on devices that have been
        /// jailbroken or otherwise modified in ways that compromise security.
        ///
        /// **Recovery:** This error cannot be resolved on compromised devices. Inform the user
        /// that provisioning is not available on their device.
        case deviceEnvironmentUnsafe

        /// The provisioning operation failed during execution in the Wallet Extension.
        ///
        /// A general failure occurred during the extension's provisioning flow. This may be
        /// due to network issues, server problems, or other runtime errors.
        ///
        /// **Recovery:** Retry the operation. If the error persists, check network connectivity
        /// and server status.
        case operationFailure

        static func from(_ networkError: CardNetworkError.ProvisioningExtensionFailure) -> Self {
            switch networkError {
            case .walletExtensionAppGroupIDNotFound: return .walletExtensionAppGroupIDNotFound
            case .cardNotFound: return .cardNotFound
            case .deviceEnvironmentUnsafe: return .deviceEnvironmentUnsafe
            case .operationFailure: return .operationFailure
            }
        }
    }

    /// Errors that occur when querying card digitization state.
    ///
    /// These errors are encountered when checking whether a card has been added to Apple Wallet
    /// and its current digitization status across devices.
    ///
    /// - SeeAlso: ``DigitizationState``, ``DigitizationData``
    public enum DigitizationStateFailure: Error, Equatable {
        /// The configuration for querying digitization state was invalid.
        ///
        /// This indicates a problem with the parameters or setup required to check
        /// the card's digitization status.
        ///
        /// **Recovery:** Review the card configuration and ensure push provisioning
        /// has been properly configured.
        case configurationFailure
        
        /// The operation to retrieve digitization state failed.
        ///
        /// A failure occurred while attempting to query the card's digitization status.
        /// This may be due to network issues or server problems.
        ///
        /// **Recovery:** Retry the operation. Check network connectivity if the error persists.
        case operationFailure

        static func from(_ networkError: CardNetworkError.DigitizationStateFailure) -> Self {
            switch networkError {
            case .configurationFailure: return .configurationFailure
            case .operationFailure: return .operationFailure
            }
        }
    }

    /// Errors related to copying sensitive card data.
    ///
    /// These errors occur when attempting to copy sensitive card information (such as PAN or CVV)
    /// to the device's pasteboard for user convenience.
    public enum CopySensitiveDataError: Error, Equatable {
        /// The copy operation failed.
        ///
        /// Unable to copy the sensitive data to the pasteboard. This may be due to
        /// system restrictions or security policies.
        ///
        /// **Recovery:** Ensure the app has necessary permissions and try again.
        case copyFailure
        
        /// The sensitive data has not been viewed yet.
        ///
        /// Copy operations are only allowed after the user has viewed the sensitive data.
        /// This security measure ensures the user is aware of what is being copied.
        ///
        /// **Recovery:** Display the sensitive data to the user first, then allow copying.
        case dataNotViewed
        
        /// The card manager reference is missing.
        ///
        /// The ``CheckoutCardManager`` instance required for the operation has been deallocated.
        ///
        /// **Recovery:** Ensure the ``CheckoutCardManager`` is retained in memory for the
        /// duration of card operations.
        case missingManager

        static func from(_ networkError: CardNetworkError.CopySensitiveDataError) -> Self {
            switch networkError {
            case .copyFailure:
                return .copyFailure
            case .dataNotViewed:
                return .dataNotViewed
            }
        }
    }

    /// The session authentication has failed.
    ///
    /// The provided session token was rejected or is no longer valid. All functionality
    /// requiring authentication will be unavailable until a successful authentication occurs.
    ///
    /// **Recovery:** Obtain a new session token and call ``CheckoutCardManager/logInSession(token:)``
    /// again to re-authenticate.
    ///
    /// - SeeAlso: ``CheckoutCardManager/logInSession(token:)``
    case authenticationFailure

    /// The SDK or operation configuration is incorrect.
    ///
    /// A configuration issue has been detected that prevents the operation from completing.
    /// The `hint` parameter provides specific guidance on what needs to be corrected.
    ///
    /// - Parameter hint: Specific advice on the configuration problem and how to resolve it.
    ///
    /// **Recovery:** Review the hint message, correct the configuration issue, and retry.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if case .configurationIssue(let hint) = error {
    ///     print("Configuration problem: \(hint)")
    /// }
    /// ```
    case configurationIssue(hint: String)

    /// A network or server connectivity issue has occurred.
    ///
    /// The operation failed due to network conditions, server unavailability, or
    /// communication problems between the device and backend services.
    ///
    /// **Recovery:** Check the device's network connection and retry. If the problem
    /// persists, the backend services may be temporarily unavailable.
    case connectionIssue

    /// The device does not support card payment operations.
    ///
    /// This device cannot perform card operations due to hardware limitations,
    /// parental controls, device restrictions, or other system-level constraints.
    ///
    /// **Recovery:** This error cannot be resolved programmatically. Inform the user
    /// that their device does not support this functionality.
    case deviceNotSupported

    /// The device has failed security validation.
    ///
    /// Internal security checks have detected that the device is jailbroken, rooted,
    /// or otherwise compromised. For security reasons, card operations are not available.
    ///
    /// **Recovery:** This error cannot be resolved on compromised devices. Inform the user
    /// that card operations are not available on their device for security reasons.
    case insecureDevice

    /// The requested card state transition is invalid.
    ///
    /// The requested card state change is not allowed from the card's current state.
    /// Not all state transitions are valid based on the card's current status.
    ///
    /// **Recovery:** Review the ``CardState`` documentation for valid state transitions
    /// and ensure the requested state change is permitted.
    ///
    /// - SeeAlso: ``CardState``, ``Card/state``
    case invalidNewCardStateRequested

    /// The input parameters for the request are invalid.
    ///
    /// One or more input parameters could not be properly formatted or validated.
    /// This typically indicates that provided data doesn't meet the expected format or requirements.
    ///
    /// **Recovery:** Review the method documentation for input requirements and ensure
    /// all parameters meet the specified format and validation rules.
    case invalidRequestInput

    /// The CheckoutCardManager instance has been deallocated.
    ///
    /// The ``CheckoutCardManager`` required for this operation is no longer in memory.
    /// All card operations require the manager to remain allocated.
    ///
    /// **Recovery:** Ensure your ``CheckoutCardManager`` instance is retained (stored as
    /// a strong reference) for the entire duration of card operations.
    ///
    /// - Important: Store the manager as a property of a long-lived object, not as a local variable.
    case missingManager

    /// No authenticated session is available.
    ///
    /// The operation requires an authenticated session, but ``CheckoutCardManager/logInSession(token:)``
    /// has not been called, or the previous token was rejected.
    ///
    /// **Recovery:** Call ``CheckoutCardManager/logInSession(token:)`` with a valid session token
    /// before attempting this operation.
    ///
    /// - SeeAlso: ``CheckoutCardManager/logInSession(token:)``
    case unauthenticated

    /// A secure operation could not be completed safely.
    ///
    /// There was a problem that prevented the secure retrieval or handling of sensitive information.
    /// This may be due to cryptographic failures, secure enclave issues, or other security-related problems.
    ///
    /// **Recovery:** Retry the operation. If the error persists, the device may have security-related
    /// issues preventing secure operations.
    case unableToPerformSecureOperation

    /// The requested card state is not available.
    ///
    /// An attempt was made to change the card to a state that is not supported or available.
    ///
    /// **Recovery:** Verify the target state is valid for the card type and current context.
    ///
    /// - SeeAlso: ``CardState``
    case invalidStateRequested

    /// Push provisioning to Apple Wallet failed.
    ///
    /// The operation to add a card to Apple Wallet encountered an error. The associated
    /// ``PushProvisioningFailure`` provides specific details about the failure.
    ///
    /// - Parameter failure: Specific push provisioning error details.
    ///
    /// - SeeAlso: ``PushProvisioningFailure``, ``CheckoutCardManager/configurePushProvisioning(cardholderID:appGroupId:configuration:walletCards:)``
    case pushProvisioningFailure(failure: PushProvisioningFailure)

    /// Failed to retrieve card digitization state.
    ///
    /// The operation to query whether the card is in Apple Wallet failed. The associated
    /// ``DigitizationStateFailure`` provides specific details about the failure.
    ///
    /// - Parameter failure: Specific digitization state query error details.
    ///
    /// - SeeAlso: ``DigitizationStateFailure``, ``DigitizationState``
    case fetchDigitizationStateFailure(failure: DigitizationStateFailure)

    /// Failed to copy sensitive card data.
    ///
    /// The operation to copy sensitive card information to the pasteboard failed. The associated
    /// ``CopySensitiveDataError`` provides specific details about the failure.
    ///
    /// - Parameter failure: Specific copy operation error details.
    ///
    /// - SeeAlso: ``CopySensitiveDataError``
    case unableToCopy(failure: CopySensitiveDataError)

    /// Returned when requested resource is not found
    case notFound
}

extension CardManagementError {

    static func from(_ networkError: CardNetworkError) -> Self {
        switch networkError {
        case .unauthenticated:
            return .unauthenticated
        case .authenticationFailure:
            return .authenticationFailure
        case .serverIssue:
            return .connectionIssue
        case .deviceNotSupported:
            return .deviceNotSupported
        case .insecureDevice:
            return .insecureDevice
        case .invalidRequest(hint: let hint):
            return .configurationIssue(hint: hint)
        case .misconfigured(hint: let hint):
            return .configurationIssue(hint: hint)
        case .invalidRequestInput:
            return .invalidRequestInput
        case .secureOperationsFailure:
            return .unableToPerformSecureOperation
        case .parsingFailure:
            return .connectionIssue
        case .pushProvisioningFailure(let failure):
            return .pushProvisioningFailure(failure: .from(failure))
        case .fetchDigitizationStateFailure(failure: let failure):
            return .fetchDigitizationStateFailure(failure: .from(failure))
        case .unableToCopy(let failure):
            return .unableToCopy(failure: .from(failure))
        case .notFound:
            return .notFound
        }
    }
}
