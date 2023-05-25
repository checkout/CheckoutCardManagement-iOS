//
//  Card+Extensions.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 21/07/2022.
//

import Foundation

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement

typealias CardState = CheckoutCardManagement.CardState
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub

typealias CardState = CheckoutCardManagementStub.CardState
#endif

extension Card: Identifiable {
    var expiryDateDisplay: String {
        "\(expiryDate.month) / \(expiryDate.year.suffix(2))"
    }

    var last4DigitsDisplay: String {
        "•••• \(panLast4Digits)"
    }

    var stateDisplay: String {
        switch state {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .suspended: return "Suspended"
        case .revoked: return "Revoked"

        @unknown default:
            assertionFailure("Unknown card state")
            return ""
        }
    }
}
