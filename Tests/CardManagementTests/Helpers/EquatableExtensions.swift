//
//  EquatableExtensions.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation
@testable import CheckoutCardNetwork
@testable import CheckoutCardManagement

extension PinViewConfiguration: Equatable {
    public static func == (lhs: PinViewConfiguration, rhs: PinViewConfiguration) -> Bool {
        lhs.textColor == rhs.textColor && lhs.font == rhs.font
    }
}
extension PanViewConfiguration: Equatable {
    public static func == (lhs: PanViewConfiguration, rhs: PanViewConfiguration) -> Bool {
        lhs.textColor == rhs.textColor && lhs.font == rhs.font && lhs.formatSeparator == rhs.formatSeparator
    }
}
extension SecurityCodeViewConfiguration: Equatable {
    public static func == (lhs: SecurityCodeViewConfiguration, rhs: SecurityCodeViewConfiguration) -> Bool {
        lhs.textColor == rhs.textColor && lhs.font == rhs.font
    }
}

extension CardManagementDesignSystem: Equatable {
    public static func == (lhs: CardManagementDesignSystem, rhs: CardManagementDesignSystem) -> Bool {
        lhs.pinFont == rhs.pinFont &&
        lhs.pinTextColor == rhs.pinTextColor &&
        lhs.panFont == rhs.panFont &&
        lhs.panTextColor == rhs.panTextColor &&
        lhs.panTextSeparator == rhs.panTextSeparator &&
        lhs.securityCodeFont == rhs.securityCodeFont &&
        lhs.securityCodeTextColor == rhs.securityCodeTextColor
    }
}

extension CheckoutCardManagement.Card: Equatable {
    
    public static func == (lhs: CheckoutCardManagement.Card, rhs: CheckoutCardManagement.Card) -> Bool {
        lhs.id == rhs.id &&
        lhs.expiryDate == rhs.expiryDate &&
        lhs.panLast4Digits == rhs.panLast4Digits &&
        lhs.cardHolderName == rhs.cardHolderName
    }
    
}
