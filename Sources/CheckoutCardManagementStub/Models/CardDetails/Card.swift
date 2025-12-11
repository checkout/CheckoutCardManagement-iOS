//
//  Card.swift
//  
//
//  Created by Alex Ioja-Yang on 08/06/2022.
//

import CheckoutCardNetworkStub

/// Represents a payment card with its details and current state.
///
/// A `Card` object contains essential information about a payment card including its state,
/// last 4 PAN digits, expiry date, cardholder name, and unique identifier. Card objects are
/// created and managed by ``CheckoutCardManager`` and provide access to card-specific operations.
///
/// **Important:** Card objects are obtained through ``CheckoutCardManager/getCards()`` or
/// ``CheckoutCardManager/getCards(completionHandler:)``. Do not attempt to create Card instances directly.
///
/// Each Card maintains a weak reference to its managing ``CheckoutCardManager``. Ensure the
/// manager remains in memory for the lifetime of any card operations.
///
/// ## Usage
///
/// ```swift
/// // Retrieve cards from the manager
/// let cards = try await cardManager.getCards()
///
/// // Access card properties
/// for card in cards {
///     print("Card ending in: \(card.panLast4Digits)")
///     print("Expires: \(card.expiryDate)")
///     print("Status: \(card.state)")
/// }
/// ```
///
/// - SeeAlso: ``CheckoutCardManager``, ``CardState``, ``CardExpiryDate``
public final class Card {

    /// The current state of the card.
    ///
    /// Indicates whether the card is active, inactive, suspended, or in another state.
    /// The state can be modified through card management operations and reflects the
    /// card's current usability for transactions.
    ///
    /// - SeeAlso: ``CardState``
    public internal(set) var state: CardState

    /// The last 4 digits of the card's Primary Account Number (PAN).
    ///
    /// This value is safe to display in user interfaces for card identification purposes.
    /// The full PAN is never exposed through this SDK for security reasons.
    ///
    /// ## Example
    ///
    /// ```swift
    /// print("Card ending in \(card.panLast4Digits)")  // "Card ending in 1234"
    /// ```
    public let panLast4Digits: String

    /// The expiry date for the card.
    ///
    /// Contains the month and year when the card expires. This information is used
    /// for display purposes and validation of card validity.
    ///
    /// - SeeAlso: ``CardExpiryDate``
    public let expiryDate: CardExpiryDate

    /// The name of the cardholder as it appears on the card.
    ///
    /// This is the display name associated with the card and is typically shown
    /// in user interfaces when presenting card details.
    public let cardholderName: String

    /// A unique identifier for this card.
    ///
    /// This identifier is used internally for card operations and API requests.
    /// It uniquely identifies the card within the card management system.
    public let id: String

    /// A weak reference to the manager is required to enable sharing of the design system and the card service
    ///
    /// - Enables object to carry operations that depend on it
    internal weak var manager: CardManager?

    /// Minimal partial identifier for logging purposes
    internal var partIdentifier: String { String(id.suffix(4)) }

    init(networkCard: CheckoutCardNetworkStub.Card,
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
