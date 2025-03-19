//
//  CardManagementDesignSystem+Extension.swift
//  
//
//  Created by Alex Ioja-Yang on 12/05/2022.
//

import UIKit
import CheckoutCardNetwork

extension CardManagementDesignSystem {

    /// UI configuration for a secure PIN number display
    var pinViewDesign: PinViewConfiguration {
        PinViewConfiguration(font: pinFont,
                             textColor: pinTextColor)
    }

    ///  UI configuration for a secure PAN number display
    var panViewDesign: PanViewConfiguration {
        PanViewConfiguration(font: panFont,
                             textColor: panTextColor,
                             formatSeparator: panTextSeparator)
    }

    var securityCodeViewDesign: SecurityCodeViewConfiguration {
        SecurityCodeViewConfiguration(font: securityCodeFont,
                                      textColor: securityCodeTextColor)
    }
}
