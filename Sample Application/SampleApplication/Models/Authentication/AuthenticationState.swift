//
//  AuthenticationState.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 20/07/2022.
//

import Foundation

enum AuthenticationState: Equatable {
    case notAuthenticated
    case authenticated(accessToken: String)
}

extension AuthenticationState: CustomStringConvertible {
    var description: String {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case .authenticated:
            return "Authenticated"
        }
    }
}
