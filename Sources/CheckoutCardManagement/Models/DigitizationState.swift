//
//  CardDigitizationState.swift
//  Pamir
//
//  Created by Marian Enache on 03.03.2025.
//

import CheckoutCardNetwork
import Foundation
import PassKit

/// Contains the complete digitization status information for a card.
///
/// `DigitizationData` provides comprehensive information about whether a card has been
/// added to Apple Wallet on the user's devices. It includes the digitization state and
/// references to [PKPass](https://developer.apple.com/documentation/passkit/pkpass) 
/// objects for both local (iPhone) and remote (Apple Watch) devices.
///
/// This data is returned when querying a card's Apple Wallet status and is useful for
/// determining whether to show "Add to Apple Wallet" UI or other digitization-related
/// functionality.
///
/// ## Usage
///
/// ```swift
/// let digitizationData = try await card.getDigitizationState()
///
/// switch digitizationData.state {
/// case .digitized:
///     // Card is in Apple Wallet
///     print("Card added to wallet")
/// case .notDigitized:
///     // Show "Add to Apple Wallet" button
///     showAddToWalletButton()
/// case .pendingIDVLocal, .pendingIDVRemote:
///     // Activation required
///     showActivationPrompt()
/// }
/// ```
///
/// - SeeAlso: ``DigitizationState``, [PKPass](https://developer.apple.com/documentation/passkit/pkpass)
public struct DigitizationData {

    /// The current digitization state of the card.
    ///
    /// Indicates whether the card is digitized, not digitized, or pending activation
    /// on the user's devices.
    ///
    /// - SeeAlso: ``DigitizationState``
    public let state: DigitizationState

    /// The PKPass for the card on the local device (iPhone or iPad).
    ///
    /// This property contains the [PKPass](https://developer.apple.com/documentation/passkit/pkpass) 
    /// object if the card has been added to Apple Wallet on the mobile device. Returns `nil` 
    /// if the card is not in the local device's wallet.
    ///
    /// - SeeAlso: [PKPass Documentation](https://developer.apple.com/documentation/passkit/pkpass)
    public let localPKPass: PKPass?

    /// The PKPass for the card on the remote device (Apple Watch).
    ///
    /// This property contains the [PKPass](https://developer.apple.com/documentation/passkit/pkpass) 
    /// object if the card has been added to Apple Wallet on the paired Apple Watch. Returns `nil` 
    /// if the card is not in the watch's wallet or if no Apple Watch is paired.
    ///
    /// - SeeAlso: [PKPass Documentation](https://developer.apple.com/documentation/passkit/pkpass)
    public let remotePKPass: PKPass?

    static func from(_ data: CardDigitizationData) -> Self {
        return DigitizationData(state: DigitizationState.from(data.state), localPKPass: data.localPKPass, remotePKPass: data.remotePKPass)
    }
}

/// Represents the Apple Wallet digitization state of a card.
///
/// `DigitizationState` indicates whether a card has been successfully added to Apple Wallet
/// and whether any activation steps are required. This state is used to determine the appropriate
/// UI to show to the user, such as an "Add to Apple Wallet" button or an activation prompt.
///
/// The state considers both local devices (iPhone/iPad) and remote devices (Apple Watch),
/// and provides specific guidance for each scenario.
///
/// ## Usage
///
/// ```swift
/// let digitizationData = try await card.getDigitizationState()
///
/// switch digitizationData.state {
/// case .digitized:
///     hideAddToWalletButton()
/// case .notDigitized:
///     showAddToWalletButton()
/// case .pendingIDVLocal:
///     showActivationPrompt(for: .phone)
/// case .pendingIDVRemote:
///     showActivationPrompt(for: .watch)
/// }
/// ```
///
/// - SeeAlso: ``DigitizationData``, [PKAddPassButton](https://developer.apple.com/documentation/passkit/pkaddpassbutton)
public enum DigitizationState: String, Decodable {

    /// The card is already digitized on all associated devices.
    ///
    /// The card has been successfully added to Apple Wallet on all relevant devices
    /// (local and/or remote) and is ready for use. No further action is required.
    case digitized

    /// The card has not been digitized on all associated devices.
    ///
    /// The card is available for provisioning to Apple Wallet. When this state is returned,
    /// you should display an "Add to Apple Wallet" button using 
    /// [PKAddPassButton](https://developer.apple.com/documentation/passkit/pkaddpassbutton)
    /// to allow the user to add the card.
    ///
    /// - SeeAlso: [PKAddPassButton](https://developer.apple.com/documentation/passkit/pkaddpassbutton)
    case notDigitized

    /// Activation is required for card digitization on the mobile device.
    ///
    /// The card has been added to Apple Wallet on the local device (iPhone/iPad), but
    /// identity verification or activation is pending. Prompt the user to complete the
    /// activation process before the card can be used for payments.
    case pendingIDVLocal

    /// Activation is required for card digitization on Apple Watch.
    ///
    /// The card has been added to Apple Wallet on the paired Apple Watch, but identity
    /// verification or activation is pending. Prompt the user to complete the activation
    /// process on their Apple Watch before the card can be used for payments.
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
