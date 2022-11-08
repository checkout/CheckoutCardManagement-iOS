//
//  CheckoutEventLogging+Extension.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
import CheckoutEventLoggerKit

extension CheckoutEventLogging {
    
    /// Convenience method wrapping formatting from project specific Event format to generic SDK expectation
    func log(_ event: LogEvent, startedAt date: Date? = nil) {
        log(event: LogFormatter.build(event: event, startedAt: date))
    }
    
}
