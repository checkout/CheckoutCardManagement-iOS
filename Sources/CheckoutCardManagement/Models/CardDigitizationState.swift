//
//  CardDigitizationState.swift
//  Pamir
//
//  Created by Marian Enache on 03.03.2025.
//

import Foundation

/// Describe the digitization state of a card
public enum DigitizationState: String, Decodable {
    
    /// Card is already digitized on all associated devices.
    case digitized
    
    /// Card has not been digitized on all associated devices. Integrator should display "Add to Apple Wallet" button using [PKAddPassButton](https://developer.apple.com/documentation/passkit/pkaddpassbutton).
    case notDigitized
    
    /// Activation is required for card digitization on mobile device.  Integrator should request end user to activate the card.
    case pendingIDVLocal
    
    /// Activation is required for card digitization on Apple Watch. Integrator should request user to activate the card.
    case pendingIDVRemote
    
    static func from(_ state: CardDigitizationState) -> Self {
        switch state {
        case .digitized: return .digitized
        case .notDigitized: return .notDigitized
        case .pendingIDVLocal: return .pendingIDVLocal
        case .pendingIDVRemote: return .pendingIDVRemote
        }
    }
}
