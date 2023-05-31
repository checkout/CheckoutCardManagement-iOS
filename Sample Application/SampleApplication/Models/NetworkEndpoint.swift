//
//  NetworkEndpoint.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 24/10/2022.
//

import Foundation
import CheckoutNetwork

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

/*
Below endpoints are just for sampling purposes and
your own backend services should provide a token on request.
 
Please see the detailed note in the Authenticator.swift file.
*/

enum NetworkEndpoint: NetworkPath {
    case authentication

    func url() -> URL {
        switch self {
        case .authentication:
            return environment == .production ?
            URL(string: "https://api.checkout.com/issuing/access/connect/token")! :
            URL(string: "https://api.sandbox.checkout.com/issuing/access/connect/token")!
        }
    }
}
