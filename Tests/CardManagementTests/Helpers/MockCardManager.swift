//
//  MockCardManager.swift
//  
//
//  Created by Alex Ioja-Yang on 15/06/2022.
//

import XCTest
import CheckoutEventLoggerKit
@testable import CheckoutCardManagement
@testable import CheckoutCardNetwork


class MockCardManager: CardManager {
    var cardService: CardService = MockCardService(environment: .sandbox)
    var logger: CheckoutEventLogging? = nil
    var designSystem = CardManagementDesignSystem(font: UIFont.boldSystemFont(ofSize: 12),
                                                  textColor: .purple)
}
