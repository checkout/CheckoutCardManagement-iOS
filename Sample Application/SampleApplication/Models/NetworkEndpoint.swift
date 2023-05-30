//
//  NetworkEndpoint.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 24/10/2022.
//

import Foundation
import CheckoutCardManagement
import CheckoutNetwork

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
