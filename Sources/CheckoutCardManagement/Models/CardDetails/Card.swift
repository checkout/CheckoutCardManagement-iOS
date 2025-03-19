//
//  Card.swift
//  
//
//  Created by Alex Ioja-Yang on 08/06/2022.
//

import CheckoutCardNetwork

/// General card details
public final class Card {

    /// Current state of the card
    public internal(set) var state: CardState

    /// Last 4 digits from the long card number
    public let panLast4Digits: String

    /// Expiry date for the card
    public let expiryDate: CardExpiryDate

    /// Name of the cardholder
    public let cardholderName: String

    /// Identifier used to identify object for external operations
    public let id: String

    /// A weak reference to the manager is required to enable sharing of the design system and the card service
    ///
    /// - Enables object to carry operations that depend on it
    internal weak var manager: CardManager?

    /// Minimal partial identifier for logging purposes
    internal var partIdentifier: String { String(id.suffix(4)) }

    init(networkCard: CheckoutCardNetwork.Card,
         manager: CardManager?) {
        self.id = networkCard.id
        self.panLast4Digits = networkCard.panLast4Digits
        self.expiryDate = networkCard.expiryDate
        self.state = networkCard.state
        self.cardholderName = networkCard.displayName
        self.manager = manager
    }

    init(id: String,
         panLast4Digits: String,
         expiryDate: CardExpiryDate,
         cardHolderName: String,
         state: CardState = .inactive,
         manager: CardManager?) {
        self.id = id
        self.panLast4Digits = panLast4Digits
        self.expiryDate = expiryDate
        self.cardholderName = cardHolderName
        self.state = state
        self.manager = manager
    }

}
