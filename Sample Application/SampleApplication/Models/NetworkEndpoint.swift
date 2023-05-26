//
//  NetworkEndpoint.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 24/10/2022.
//

import Foundation
import CheckoutNetwork

enum NetworkEndpoint: NetworkPath {

    case authentication

    func url() -> URL {
        switch self {
        case .authentication:
#if canImport(CheckoutCardManagementStub)
            return URL(string: "https://api.sandbox.checkout.com/issuing/access/connect/token")!
#else
            return URL(string: "https://api.checkout.com/issuing/access/connect/token")!
#endif
        }

    }
}
