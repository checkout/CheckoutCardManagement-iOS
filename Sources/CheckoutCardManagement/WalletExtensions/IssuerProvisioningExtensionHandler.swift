//
//  IntentHandler.swift
//  WalletExtension
//
//  Created by Marian Enache on 14.02.2025.
//

import CheckoutCardNetwork
import CheckoutEventLoggerKit

@available(iOS 14.0, *)
open class IssuerProvisioningExtensionHandler: CKOIssuerProvisioningExtensionHandler {

    public override init() {
        super.init()
        let eventLogger = CheckoutEventLogger(productName: Constants.productName)
        let logger = CheckoutLogger(eventLogger: eventLogger)
        initLogger(logger: logger)
    }

    final public override func onError(_ error: CardNetworkError.ProvisioningExtensionFailure) {
        onError(.from(error))
    }

    open func onError(_ error: CardManagementError.ProvisioningExtensionFailure) {

    }
}
