//
//  DictionaryLogging+Extension.swift
//  
//
//  Created by Alex Ioja-Yang on 20/09/2022.
//

import Foundation
import CheckoutEventLoggerKit

extension Dictionary<String, AnyCodable> {
    
    mutating func addTimeSince(startDate: Date?) {
        guard let date = startDate,
        let doubleTimeGap = Double(String(format: "%.2f", Date().timeIntervalSince(date))) else {
            return
        }
        self["duration"] = AnyCodable(doubleTimeGap)
    }
    
}
