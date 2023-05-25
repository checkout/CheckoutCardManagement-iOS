// 
//  CheckoutCardManagerFactory.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 16/03/2023.
//

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

extension CheckoutCardManager {

    /// Example initialiser integrating your own Design System
    convenience init(demoEnvironment: CardManagerEnvironment) {
        let design = DesignSystem.CardManagement.self
        var designSystem = CardManagementDesignSystem(font: design.pin.font,
                                                      textColor: design.pin.textColor)
        designSystem.panFont = design.pan.font
        designSystem.panTextColor = design.pan.textColor
        designSystem.panTextSeparator = design.panTextSeparator
        designSystem.securityCodeFont = design.securityCode.font
        designSystem.securityCodeTextColor = design.securityCode.textColor

        self.init(designSystem: designSystem,
                  environment: demoEnvironment)
    }

}
