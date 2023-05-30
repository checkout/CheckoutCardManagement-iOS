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
 Where documented, you are required to perform Strong Customer Authentication (SCA)
 in accordance to your company's policies and processes.
 The sample project integrates directly with CKO backend for token creation in order to enable the flows,
 but in a live application this is expected to occur from your backend to CKO backend and not be performed via your application.

 In addition, you can assess CheckoutNetwork as a network wrapper that you will not use.
 */

struct Authenticator {
    private let networkClient: CheckoutNetworkClient = .init()
    
    func authenticateUser(performSCA: Bool = true,
                          completionHandler: @escaping ((Result<String, Error>) -> Void)) {
        
        guard performSCA else {
            authenticate(isSingleUse: performSCA,
                         completionHandler: completionHandler)
            return
        }
        
        AuthenticationValidator.isDeviceOwner { isDeviceOwner in
            guard isDeviceOwner else {
                completionHandler(.failure(CardManagementError.authenticationFailure))
                print("SCA Failed! To pass make sure you provide any input to the check")
                return
            }
            authenticate(isSingleUse: performSCA,
                         completionHandler: completionHandler)
        }
    }
    
    private func authenticate(isSingleUse: Bool,
                              completionHandler: @escaping ((Result<String, Error>) -> Void)) {
        
#if canImport(CheckoutCardManagementStub)
        completionHandler(.success("ANY_TOKEN"))
#else
        let authenticationCredentials = Configuration.makeAuthenticationCredentials(cardholderID: AuthenticationCredentials.cardholderID,
                                                                                    isSingleUse: isSingleUse)
        guard let serializedBody = authenticationCredentials.serialized(),
              let authenticationData = serializedBody.data(using: .utf8),
              let authenticateConfig = try? RequestConfiguration(path: NetworkEndpoint.authentication,
                                                                 httpMethod: .post,
                                                                 customHeaders: [:],
                                                                 bodyData: authenticationData,
                                                                 mimeType: .urlEncodedForm) else {
            completionHandler(.failure(CardManagementError.configurationIssue(hint: "Could not create authentication request")))
            return
        }
        
        networkClient.runRequest(with: authenticateConfig) { (authenticationResult: Result<Token, Error>) in
            switch authenticationResult {
            case .success(let token):
                completionHandler(.success(token.accessToken))
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(.failure(error))
            }
        }
#endif
    }
}
