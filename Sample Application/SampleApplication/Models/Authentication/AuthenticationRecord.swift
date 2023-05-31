// 
//  AuthenticationRecord.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 03/04/2023.
//

import Foundation

class AuthenticationRecord: ObservableObject {
    @Published var state: AuthenticationState = .notAuthenticated
}
