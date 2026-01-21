//
//  CardManagementError+DebugDescriptions.swift
//  CheckoutCardManagement
//
//  Created by Tinashe Makuti on 15/01/2026.
//

import Foundation

extension CardManagementError {
    
    /// A detailed, human-readable description of the error for debugging purposes.
    public var debugDescription: String {
        switch self {
        case .authenticationFailure:
            """
            [CardManagementError.authenticationFailure] Session authentication failed. \
            The provided session token was rejected or is no longer valid. \
            Obtain a new session token from your backend and call logInSession(token:) to re-authenticate.
            """
            
        case .configurationIssue(let hint):
            """
            [CardManagementError.configurationIssue] SDK configuration error: \(hint). \
            Review the configuration parameters and ensure they meet the SDK requirements.
            """
            
        case .connectionIssue:
            """
            [CardManagementError.connectionIssue] Network or server connectivity issue. \
            This may be caused by: network unavailability, server errors, or response parsing failures. \
            Check device network connection and retry. If the issue persists, backend services may be temporarily unavailable.
            """
            
        case .deviceNotSupported:
            """
            [CardManagementError.deviceNotSupported] This device does not support card payment operations. \
            Possible causes: hardware limitations, parental control restrictions, or device-level constraints. \
            This error cannot be resolved programmatically.
            """
            
        case .insecureDevice:
            """
            [CardManagementError.insecureDevice] Device security validation failed. \
            The device has been detected as jailbroken, rooted, or otherwise compromised. \
            Card operations are blocked for security reasons and cannot be performed on this device.
            """
            
        case .invalidNewCardStateRequested:
            """
            [CardManagementError.invalidNewCardStateRequested] Invalid card state transition requested. \
            The requested state change is not allowed from the card's current state. \
            Check Card.possibleStateChanges to determine valid state transitions for the current card state.
            """
            
        case .invalidRequestInput:
            """
            [CardManagementError.invalidRequestInput] One or more input parameters are invalid. \
            The provided data does not meet the expected format or validation requirements. \
            Review the method documentation for input requirements and ensure all parameters are correctly formatted.
            """
            
        case .missingManager:
            """
            [CardManagementError.missingManager] CheckoutCardManager instance has been deallocated. \
            The manager required for this operation is no longer in memory. \
            Ensure CheckoutCardManager is retained as a strong reference (e.g., as a class property) for the duration of card operations.
            """
            
        case .unauthenticated:
            """
            [CardManagementError.unauthenticated] No authenticated session available. \
            The operation requires authentication, but logInSession(token:) has not been called or the session has expired. \
            Call logInSession(token:) with a valid session token before attempting this operation.
            """
            
        case .unableToPerformSecureOperation:
            """
            [CardManagementError.unableToPerformSecureOperation] Secure operation failed. \
            Unable to securely retrieve or handle sensitive information. \
            This may be due to cryptographic failures, Secure Enclave issues, or other security-related problems. \
            Retry the operation. If the error persists, the device may have security-related limitations.
            """
            
        case .invalidStateRequested:
            """
            [CardManagementError.invalidStateRequested] The target card state is not available. \
            The requested state is not supported or cannot be applied to this card. \
            Verify the target state is valid for the card type and current context.
            """
            
        case .pushProvisioningFailure(let failure):
            "[CardManagementError.pushProvisioningFailure] Apple Wallet provisioning failed. \(failure.debugDescription)"
            
        case .fetchDigitizationStateFailure(let failure):
            "[CardManagementError.fetchDigitizationStateFailure] Failed to query card digitization state. \(failure.debugDescription)"
            
        case .unableToCopy(let failure):
            "[CardManagementError.unableToCopy] Failed to copy sensitive card data to clipboard. \(failure.debugDescription)"
            
        case .notFound:
            """
            [CardManagementError.notFound] Requested resource not found. \
            The card or resource being accessed does not exist or is not available for the current cardholder.
            """
        }
    }
}

// MARK: - Nested Error Debug Descriptions

extension CardManagementError.PushProvisioningFailure {
    
    /// A detailed debug description for push provisioning failures.
    public var debugDescription: String {
        switch self {
        case .cancelled:
            """
            [PushProvisioningFailure.cancelled] User cancelled the Apple Wallet provisioning flow. \
            The user explicitly dismissed or cancelled the provisioning process. \
            No action required unless the user initiates the flow again.
            """
            
        case .configurationFailure:
            """
            [PushProvisioningFailure.configurationFailure] Push provisioning configuration was rejected. \
            The configuration parameters provided to configurePushProvisioning are invalid. \
            Review the configuration parameters and ensure they meet Apple Wallet requirements.
            """
            
        case .operationFailure:
            """
            [PushProvisioningFailure.operationFailure] Provisioning operation failed during execution. \
            This may be caused by network issues, server problems, or runtime errors. \
            Retry the operation. Check network connectivity if the error persists.
            """
        }
    }
}

extension CardManagementError.ProvisioningExtensionFailure {
    
    /// A detailed debug description for provisioning extension failures.
    public var debugDescription: String {
        switch self {
        case .walletExtensionAppGroupIDNotFound:
            """
            [ProvisioningExtensionFailure.walletExtensionAppGroupIDNotFound] App Group ID not found. \
            The App Group identifier required for Wallet Extension data sharing was not configured. \
            Configure an App Group in your project and provide the correct identifier to configurePushProvisioning.
            """
            
        case .cardNotFound:
            """
            [ProvisioningExtensionFailure.cardNotFound] Card not found for provisioning. \
            The Wallet Extension attempted to provision a card that doesn't exist or is unavailable. \
            Verify the card ID and ensure the card is available for the current cardholder.
            """
            
        case .deviceEnvironmentUnsafe:
            """
            [ProvisioningExtensionFailure.deviceEnvironmentUnsafe] Device environment is compromised. \
            The device has been detected as jailbroken or rooted. \
            Card provisioning is blocked for security reasons and cannot be performed on this device.
            """
            
        case .operationFailure:
            """
            [ProvisioningExtensionFailure.operationFailure] Wallet Extension provisioning operation failed. \
            A failure occurred during the extension's provisioning flow. \
            Retry the operation. Check network connectivity and server status if the error persists.
            """
        }
    }
}

extension CardManagementError.DigitizationStateFailure {
    
    /// A detailed debug description for digitization state failures.
    public var debugDescription: String {
        switch self {
        case .configurationFailure:
            """
            [DigitizationStateFailure.configurationFailure] Digitization state query configuration invalid. \
            The parameters or setup required to check the card's digitization status are incorrect. \
            Review the card configuration and ensure push provisioning has been properly configured.
            """
            
        case .operationFailure:
            """
            [DigitizationStateFailure.operationFailure] Failed to retrieve digitization state. \
            The operation to query whether the card is in Apple Wallet failed. \
            This may be due to network issues or server problems. Retry the operation.
            """
        }
    }
}

extension CardManagementError.CopySensitiveDataError {
    
    /// A detailed debug description for copy sensitive data errors.
    public var debugDescription: String {
        switch self {
        case .copyFailure:
            """
            [CopySensitiveDataError.copyFailure] Failed to copy data to clipboard. \
            Unable to copy sensitive data to the device pasteboard. \
            This may be due to system restrictions or security policies. Ensure the app has necessary permissions.
            """
            
        case .dataNotViewed:
            """
            [CopySensitiveDataError.dataNotViewed] Sensitive data has not been viewed yet. \
            Copy operations are only allowed after the user has viewed the sensitive data. \
            Display the sensitive data to the user first using getPan, or getPanAndSecurityCode before allowing copy.
            """
            
        case .missingManager:
            """
            [CopySensitiveDataError.missingManager] CheckoutCardManager instance is missing. \
            The card manager required for the copy operation has been deallocated. \
            Ensure CheckoutCardManager is retained as a strong reference for the duration of card operations.
            """
        }
    }
}
