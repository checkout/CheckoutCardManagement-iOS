//
//  CheckoutEventLogging+Extension.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
import CheckoutEventLoggerKit
import CheckoutCardNetwork

extension CheckoutEventLogging {
    
    /// Convenience method wrapping formatting from project specific Event format to generic SDK expectation
    func log(_ event: LogEvent, startedAt date: Date? = nil) {
        log(event: LogFormatter.build(event: event, startedAt: date))
    }
    
}

extension CheckoutEventLogger: NetworkLogger {
    
    public func log(error: Error, additionalInfo: [String : String]) {
        log(event: LogFormatter.build(event: .failure(source: additionalInfo["source"] ?? "", error: error),
                                      extraProperties: additionalInfo))
    }
}
