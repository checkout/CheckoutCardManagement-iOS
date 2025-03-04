//
//  CardManagementError.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation
import CheckoutCardNetworkStub

/// Errors encountered in the running of the management services
public enum CardManagementError: Error, Equatable {
    
    /// Contain more detailed push provisioning failures
    public enum PushProvisioningFailure: Error, Equatable {
        /// User has cancelled the operation at some point during the flow
        case cancelled

        /// The configuration used to setup Push Provisioning was rejected
        case configurationFailure

        /// The flow has failed during the execution
        case operationFailure
        
        static func from(_ networkError: CardNetworkError.PushProvisioningFailure) -> Self {
            switch networkError {
            case .cancelled: return .cancelled
            case .configurationFailure: return .configurationFailure
            case .operationFailure: return .operationFailure
            }
        }
    }
    
    public enum ProvisioningExtensionFailure: Error, Equatable {
        /// User has cancelled the operation at some point during the flow
        case walletExtensionAppGroupIDNotFound
        case notLoggedIn
        case cardNotFound
        case deviceEnvironmentUnsafe
        case operationFailure
        
        static func from (_ networkError: CardNetworkError.ProvisioningExtensionFailure) -> Self {
            switch networkError {
            case .walletExtensionAppGroupIDNotFound: return .walletExtensionAppGroupIDNotFound
            case .notLoggedIn: return .notLoggedIn
            case .cardNotFound: return .cardNotFound
            case .deviceEnvironmentUnsafe: return .deviceEnvironmentUnsafe
            case .operationFailure: return .operationFailure
            }
        }
    }

    public enum DigitizationStateFailure: Error, Equatable {
        case configurationFailure
        case operationFailure
        
        static func from (_ networkError: CardNetworkError.DigitizationStateFailure) -> Self {
            switch networkError {
            case .configurationFailure: return .configurationFailure
            case .operationFailure: return .operationFailure
            }
        }
    }
    
    /// The authentication of the session has failed. Functionality will not be available until a successful authentication takes place
    case authenticationFailure
    
    /// A configuration seems to not be correct. Please review configuration of SDK and any other configuration leading to the call completion
    ///
    /// - Note: Use `hint` for advice on recovering and retrying.
    case configurationIssue(hint: String)
    
    ///  There may be an issue with network conditions on device
    case connectionIssue
    
    /// Device does not support making payment. It could be because of variety of reasons,
    /// e.g. hardware functionality, parental control restriction.
    case deviceNotSupported
    
    /// Internal security tests have flagged device as unsafe. Operation rejected
    case insecureDevice
    
    /// The new card state requested was not a valid change possible from the current state
    ///
    /// For more information on the card states transitions, review CardState enum
    case invalidNewCardStateRequested
    
    /// The input required for the request could not be formatted appropriately.
    ///
    /// - Note: Review documentation for input requirements
    case invalidRequestInput
    
    /// Your CheckoutCardManager was deallocated. For all card operations, the manager is still required and you are responsible for keeping it in memory
    case missingManager
    
    /// The session is not authenticated. Provide a session token via `logInSession` and retry.
    case unauthenticated
    
    /// There was a problem that prevented securely retrieving information
    case unableToPerformSecureOperation
    
    /// Requested to change card to an unavailable state
    case invalidStateRequested
    
    /// Failed to complete Push Provisioning request
    case pushProvisioningFailure(failure: PushProvisioningFailure)
    
    /// Failed to complete Push Provisioning request
    case fetchDigitizationStateFailure(failure: DigitizationStateFailure)
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
        }
    }
    
}
