//
//  CardDetailCopyResult.swift
//  CheckoutCardManagement
//
//  Created by Tinashe Makuti on 25/07/2025.
//

import Foundation

extension CheckoutCardManager {

    /// Enum describing the result of an asynchronous operation
    @frozen
    public enum CardDetailCopyResult: Equatable {

        /// The operation was a success
        case success

        /// The operation has failed and an appropriate failure error is attached
        case failure(CardManagementError)
    }
}
