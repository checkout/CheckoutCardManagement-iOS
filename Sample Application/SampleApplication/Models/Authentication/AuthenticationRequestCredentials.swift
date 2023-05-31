//
//  AuthenticationRequestCredentials.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 27/10/2022.
//

import Foundation

struct AuthenticationRequestCredentials: Codable {
    let grantType: String
    let clientID: String
    let clientSecret: String
    let cardholderID: String?
    let isSingleUse: Bool

    func serialized() -> String? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
            return nil
        }

        return dictionary.map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            var escapedValue = ""
            if let string = value as? String {
                escapedValue = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            } else if let bool = value as? Bool {
                escapedValue = bool ? "true" : "false"
            } else {
                assertionFailure("New type of value encountered in the serialisation!")
            }
            return "\(escapedKey)=\(escapedValue)"
        }
        .joined(separator: "&")
    }

    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case cardholderID = "cardholder_id"
        case isSingleUse = "single_use"
    }
}
