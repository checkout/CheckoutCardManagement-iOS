// 
//  Authenticator.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 23/05/2023.
//

import CheckoutNetwork
import Foundation

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

/*
 Where documented, you are required to perform StrongCustomAuthentication (SCA)
 in accordance to your company's policies and processes.
 The sample project integrates directly with CKO backend for token creation in order to enable the flows,
 but in a live application this is expected to occur from your backend to CKO backend and not be performed via your application.
 Hence you can assess CheckoutNetwork as a network wrapper that you will not use.
 */

struct Authenticator {
    private let networkClient: CheckoutNetworkClient = .init()
    
    func authenticateUser(checkDeviceOwnership: Bool = true,
                          completionHandler: @escaping ((Result<String, CardManagementError>) -> Void)) {
        
        guard checkDeviceOwnership else {
            authenticate(completionHandler: completionHandler)
            return
        }
        
        AuthenticationValidator.isDeviceOwner { isDeviceOwner in
            guard isDeviceOwner else {
                completionHandler(.failure(.authenticationFailure))
                print("Please prove that you are the device owner." +
                      "If you are on simulator, you can type anything and hit Enter")
                return
            }
            authenticate(completionHandler: completionHandler)
        }
    }
    
    private func authenticate(completionHandler: @escaping ((Result<String, CardManagementError>) -> Void)) {
        
#if canImport(CheckoutCardManagementStub)
        completionHandler(.success("ANY_TOKEN"))
#else
        let authenticationCredentials = Configuration.makeAuthenticationCredentials(cardholderID: AuthenticationCredentials.cardholderID,
                                                                                    isSingleUse: true)
        guard let serializedBody = authenticationCredentials.serialized(),
              let authenticationData = serializedBody.data(using: .utf8),
              let authenticateConfig = try? RequestConfiguration(path: NetworkEndpoint.authentication,
                                                                 httpMethod: .post,
                                                                 customHeaders: [:],
                                                                 bodyData: authenticationData,
                                                                 mimeType: .urlEncodedForm) else {
            completionHandler(.failure(.configurationIssue(hint: "Could not create authentication request")))
            return
        }
        
        networkClient.runRequest(with: authenticateConfig) { (authenticationResult: Result<Token, Error>) in
            switch authenticationResult {
            case .success(let token):
                completionHandler(.success(token.accessToken))
            case .failure:
                completionHandler(.failure(.authenticationFailure))
            }
        }
#endif
    }
}
