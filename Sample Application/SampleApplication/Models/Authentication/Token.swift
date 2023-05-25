//
//  Token.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 27/10/2022.
//

import Foundation

struct Token: Decodable, Equatable {

    let accessToken: String
    let expiresAt: Date
    let tokenType: String
    let scopes: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accessToken = try container.decode(String.self, forKey: .accessToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)

        let scope = try container.decode(String.self, forKey: .scope)
        scopes = scope.components(separatedBy: " ")

        var tokenLifeTime = try container.decode(Int.self, forKey: .expiresIn)
        tokenLifeTime -= 10

        if #available(iOS 15, *) {
            expiresAt = Date(timeInterval: TimeInterval(tokenLifeTime), since: .now)
        } else {
            expiresAt = Date(timeInterval: TimeInterval(tokenLifeTime), since: Date())
        }
    }

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
    }

}
