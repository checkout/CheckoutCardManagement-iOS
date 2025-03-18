//
//  LogEvent.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
import CheckoutCardNetworkStub
import CheckoutEventLoggerKit

/// Analytics event wrappers
enum LogEvent {

    /// Describe an initialisation of the CardManager
    case initialized(design: CardManagementDesignSystem)

    /// Describe a successful retrieval of the card list
    case cardList(idSuffixes: [String])

    /// Describe a successful call to retrieve a pin
    case getPin(idLast4: String, cardState: CardState)

    /// Describe a successful call to retrieve a card number
    case getPan(idLast4: String, cardState: CardState)

    /// Describe a successful call to retrieve a security code
    case getCVV(idLast4: String, cardState: CardState)

    /// Describe a successful call to retrieve a pan and a security code
    case getPanCVV(idLast4: String, cardState: CardState)

    /// Describe a successfull event where a card state change was completed
    case stateManagement(idLast4: String, originalState: CardState, requestedState: CardState, reason: String?)

    /// Describe a successfull Configuration of Push Provisioning
    case configurePushProvisioning(last4CardholderID: String)

    /// Describe a Get Card Digitization State event
    case getCardDigitizationState(last4CardID: String, digitizationState: DigitizationState)

    /// Describe a Push Provisioning event
    case pushProvisioning(last4CardID: String)

    /// Describe an unexpected but non critical failure
    case failure(source: String, error: Error)
}
