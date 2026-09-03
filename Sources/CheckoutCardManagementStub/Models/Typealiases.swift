//
//  Typealiases.swift
//
//
//  Created by Alex Ioja-Yang on 08/06/2022.
//

import Foundation
import CheckoutCardNetworkStub

/// Expiry date for a card
public typealias CardExpiryDate = CheckoutCardNetworkStub.CardExpiryDate

/// State for a card
public typealias CardState = CheckoutCardNetworkStub.CardState

/// The type of a card (physical or virtual)
public typealias CardType = CheckoutCardNetworkStub.CardType

/// The payment network scheme for a card (e.g., Mastercard, Visa)
public typealias CardScheme = CheckoutCardNetworkStub.CardScheme

/// Digitization state of a card
public typealias CardDigitizationState = CheckoutCardNetworkStub.CardDigitizationState

/// Reason for requesting to perform a Card Suspend operation on card
public typealias CardSuspendReason = CheckoutCardNetworkStub.CardSuspendReason

/// Reason for requesting to perform a Card Revoke operation on card
public typealias CardRevokeReason = CheckoutCardNetworkStub.CardRevokeReason

/// Configuration object used for Push Provisioning
public typealias ProvisioningConfiguration = CheckoutCardNetworkStub.ProvisioningConfiguration

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionHandler = CheckoutCardNetworkStub.NonUiProvisioningExtensionHandler

@available(iOS 14.0, *)
public typealias CKOIssuerProvisioningExtensionAuthorizationProviding = CheckoutCardNetworkStub.UiProvisioningExtensionAuthorizationProviding
