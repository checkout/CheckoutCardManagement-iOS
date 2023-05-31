//
//  Configuration.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 27/10/2022.
//

import Foundation

enum Configuration {
    
    static func makeAuthenticationCredentials(cardholderID: String,
                                              isSingleUse: Bool) -> AuthenticationRequestCredentials {
        AuthenticationRequestCredentials(
            grantType: "client_credentials",
            clientID: AuthenticationCredentials.clientID,
            clientSecret: AuthenticationCredentials.clientSecret,
            cardholderID: cardholderID,
            isSingleUse: isSingleUse)
    }
    
}
