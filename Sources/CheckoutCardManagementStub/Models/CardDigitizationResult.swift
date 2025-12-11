//
//  OperationResult.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation

// Add enum under the namespace and scope of core object.
// This helps avoid conflicts with consumer codebase
extension CheckoutCardManager {

    /// Enum describing the result of an asynchronous operation
    @frozen
    public enum CardDigitizationResult {

        /// The operation was a success
        case success(DigitizationData)

        /// The operation has failed and an appropriate failure error is attached
        case failure(CardManagementError)
    }

}
