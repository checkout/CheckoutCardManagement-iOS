//
//  CardManagementError.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation
//import CheckoutCardNetwork

/// Errors encountered in the running of the management services
public enum CardManagementError: Error, Equatable {
    
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
    
}

//extension CardManagementError {
//    
//    static func from(_ networkError: CardNetworkError) -> Self {
//        switch networkError {
//        case .unauthenticated:
//            return .unauthenticated
//        case .authenticationFailure:
//            return .authenticationFailure
//        case .serverIssue:
//            return .connectionIssue
//        case .deviceNotSupported:
//            return .deviceNotSupported
//        case .insecureDevice:
//            return .insecureDevice
//        case .invalidRequest(hint: let hint):
//            return .configurationIssue(hint: hint)
//        case .misconfigured(hint: let hint):
//            return .configurationIssue(hint: hint)
//        case .invalidRequestInput:
//            return .invalidRequestInput
//        @unknown default:
//            return .configurationIssue(hint: "Unsuported network error")
//        }
//    }
//    
//}
