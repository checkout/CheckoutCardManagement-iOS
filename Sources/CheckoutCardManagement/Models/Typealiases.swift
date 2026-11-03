//
//  Typealiases.swift
//
//
//  Created by Alex Ioja-Yang on 08/06/2022.
//

import Foundation
import CheckoutCardNetwork

/// Expiry date for a card
public typealias CardExpiryDate = CheckoutCardNetwork.CardExpiryDate

/// State for a card
public typealias CardState = CheckoutCardNetwork.CardState

/// The type of a card (physical or virtual)
public typealias CardType = CheckoutCardNetwork.CardType

/// The payment network scheme for a card (e.g., Mastercard, Visa)
public typealias CardScheme = CheckoutCardNetwork.CardScheme

/// Digitization state of a card
public typealias CardDigitizationState = CheckoutCardNetwork.CardDigitizationState

/// Reason for requesting to perform a Card Suspend operation on card
public typealias CardSuspendReason = CheckoutCardNetwork.CardSuspendReason

/// Reason for requesting to perform a Card Revoke operation on card
public typealias CardRevokeReason = CheckoutCardNetwork.CardRevokeReason

/// A card transaction, as returned by ``CheckoutCardManager/getTransactions(query:)``
public typealias Transaction = CheckoutCardNetwork.Transaction

/// Status of a transaction
public typealias TransactionStatus = CheckoutCardNetwork.Transaction.TransactionStatus

/// Public Card Model for preventing name collisions
public typealias CheckoutCard = Card

/// Public Transaction Model for preventing name collisions, e.g. with `SwiftUI.Transaction`
public typealias CheckoutTransaction = Transaction

/// Configuration object used for Push Provisioning
public typealias ProvisioningConfiguration = CheckoutCardNetwork.ProvisioningConfiguration

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionHandler = CheckoutCardNetwork.NonUiProvisioningExtensionHandler

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionAuthorizationProviding = CheckoutCardNetwork.UiProvisioningExtensionAuthorizationProviding
