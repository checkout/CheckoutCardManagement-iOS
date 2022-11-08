//
//  CardManagerEnvironment.swift
//  
//
//  Created by Alex Ioja-Yang on 12/07/2022.
//

import Foundation
import CheckoutCardNetwork
import CheckoutEventLoggerKit

/// Environment for the data source
public enum CardManagerEnvironment: String {
    
    /// Development environment with a backend built for development work
    case sandbox
    
    /// Production environment meant for the real world
    case production
    
    func networkEnvironment() -> CardNetworkEnvironment {
        switch self {
        case .sandbox:
            return .sandbox
        case .production:
            return .production
        }
    }
    
    func loggingEnvironment() -> CheckoutEventLoggerKit.Environment {
        switch self {
        case .sandbox: return .sandbox
        case .production: return .production
        }
    }
    
}
