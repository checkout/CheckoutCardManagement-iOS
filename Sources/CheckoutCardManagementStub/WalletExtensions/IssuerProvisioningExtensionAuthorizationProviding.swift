//
//  IntentHandler.swift
//  WalletExtension
//
//  Created by Marian Enache on 14.02.2025.
//

import CheckoutCardNetworkStub
import CheckoutEventLoggerKit

@available(iOS 14.0, *)
public protocol IssuerProvisioningExtensionAuthorizationProviding: CKOIssuerProvisioningExtensionAuthorizationProviding {
}

@available(iOS 14.0, *)
extension IssuerProvisioningExtensionAuthorizationProviding {

    public func login(_ issuerToken: String, completion: @escaping (CardManagementError.ProvisioningExtensionFailure?) -> Void) {
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)
        
        login(token: issuerToken, logger: logger) { (error: CardNetworkError.ProvisioningExtensionFailure?) in
            if error != nil {
                completion(.from(error!))
            } else {
                completion(nil)
            }
        }
    }
}
