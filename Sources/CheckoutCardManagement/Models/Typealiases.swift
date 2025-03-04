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

/// Digitization state of a card
public typealias CardDigitizationState = CheckoutCardNetwork.CardDigitizationState

/// Reason for requesting to perform a Card Suspend operation on card
public typealias CardSuspendReason = CheckoutCardNetwork.CardSuspendReason

/// Reason for requesting to perform a Card Revoke operation on card
public typealias CardRevokeReason = CheckoutCardNetwork.CardRevokeReason

/// Configuration object used for Push Provisioning
public typealias ProvisioningConfiguration = CheckoutCardNetwork.ProvisioningConfiguration

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionHandler = CheckoutCardNetwork.NonUiProvisioningExtensionHandler

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionAuthorizationProviding = CheckoutCardNetwork.UiProvisioningExtensionAuthorizationProviding
