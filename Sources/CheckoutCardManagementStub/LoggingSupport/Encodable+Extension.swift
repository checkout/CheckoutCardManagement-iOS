//
//  Encodable+Extension.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import Foundation
import CheckoutEventLoggerKit

extension Encodable {

    /// Will convert the object to a dictionary that can be passed to the analytics logger. Can return empty dictionary if failing to decode
    func mapToLogDictionary() throws -> [String: AnyCodable] {
        let encodedData = try JSONEncoder().encode(self)
        let serialisedDictionary = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        let codableDictionary = serialisedDictionary?.compactMapValues { AnyCodable($0) }
        return codableDictionary ?? [:]
    }

}
