//
//  CardManagementDesignSystem.swift
//  
//
//  Created by Alex Ioja-Yang on 12/05/2022.
//

import UIKit

/// Collection of properties enabling the customisation of UI outputs from the framework
public struct CardManagementDesignSystem: Encodable {

    // MARK: Pin Display Formatting
    /// Font used when returning UI component with the pin number
    public var pinFont: UIFont
    /// Text color used when returning UI component with the pin number
    public var pinTextColor: UIColor

    // MARK: PAN Display Formatting
    /// Font used when returning UI component with the long card number
    public var panFont: UIFont
    /// Text color used when returning UI component with the long card number
    public var panTextColor: UIColor
    /// Text separator used to format the card number when displayed. Default is single space
    public var panTextSeparator: String = " "

    // MARK: Security code Display Formatting
    /// Font used when returning UI component with the security code
    public var securityCodeFont: UIFont
    /// Text color used when returning UI component with the security code
    public var securityCodeTextColor: UIColor

    // MARK: Initialisers

    /// Initialiser with single configuration for all returned UI components
    public init(font: UIFont,
                textColor: UIColor) {
        self.pinFont = font
        self.pinTextColor = textColor

        self.panFont = font
        self.panTextColor = textColor

        self.securityCodeFont = font
        self.securityCodeTextColor = textColor
    }

    /// Initialiser declaring the complete configuration for the design system
    public init(pinFont: UIFont,
                pinTextColor: UIColor,
                panFont: UIFont,
                panTextColor: UIColor,
                securityCodeFont: UIFont,
                securityCodeTextColor: UIColor) {
        self.pinFont = pinFont
        self.pinTextColor = pinTextColor
        self.panFont = panFont
        self.panTextColor = panTextColor
        self.securityCodeFont = securityCodeFont
        self.securityCodeTextColor = securityCodeTextColor
    }
}
