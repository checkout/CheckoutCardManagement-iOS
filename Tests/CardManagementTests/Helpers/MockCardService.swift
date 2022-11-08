//
//  MockCardService.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import Foundation
@testable import CheckoutCardNetwork
@testable import CheckoutCardManagement
import XCTest

final class MockCardService: CardService {
    
    static var version: CardServiceVersion = .init(name: "mock", number: "0")
    
    var logger: NetworkLogger?
    
    var displayPinReceivedCardIDs = [String]()
    var displayPinReceivedDisplayConfigurations = [PinViewConfiguration]()
    var displayPinResult: SecureResult?
    
    var displayPanReceivedCardIDs = [String]()
    var displayPanReceivedDisplayConfigurations = [PanViewConfiguration]()
    var displayPanResult: SecureResult?
    
    var displayCVVReceivedCardIDs = [String]()
    var displayCVVReceivedDisplayConfigurations = [SecurityCodeViewConfiguration]()
    var displayCVVResult: SecureResult?
    
    var displayPanAndCVVResult: SecurePropertiesResult?
    var receivedTokens = [String]()
    
    var getCardsResult: CardListResult?
    var getCardsCallCount = 0
    
    init() { }
    init(environment: CardNetworkEnvironment) {}
    
    /// Request to retrieve object containing a PIN number for provided card id
    func displayPin(forCard cardID: String,
                    displayConfiguration: PinViewConfiguration,
                    singleUseToken: String,
                    completionHandler: @escaping ((SecureResult) -> Void)) {
        receivedTokens.append(singleUseToken)
        displayPinReceivedCardIDs.append(cardID)
        displayPinReceivedDisplayConfigurations.append(displayConfiguration)
        
        guard let result = displayPinResult else {
            XCTFail("Method called without setting any completion!")
            return
        }
        completionHandler(result)
    }
    
    /// Request to retrieve object containing a PAN number for provided card id
    func displayPan(forCard cardID: String,
                    displayConfiguration: PanViewConfiguration,
                    singleUseToken: String,
                    completionHandler: @escaping ((SecureResult) -> Void)) {
        receivedTokens.append(singleUseToken)
        displayPanReceivedCardIDs.append(cardID)
        displayPanReceivedDisplayConfigurations.append(displayConfiguration)
        
        guard let result = displayPanResult else {
            XCTFail("Method called without setting any completion!")
            return
        }
        completionHandler(result)
    }
    
    func displaySecurityCode(forCard cardID: String,
                             displayConfiguration: SecurityCodeViewConfiguration,
                             singleUseToken: String,
                             completionHandler: @escaping ((SecureResult) -> Void)) {
        receivedTokens.append(singleUseToken)
        displayCVVReceivedCardIDs.append(cardID)
        displayCVVReceivedDisplayConfigurations.append(displayConfiguration)
        
        
        guard let result = displayCVVResult else {
            XCTFail("Method called without setting any completion!")
            return
        }
        completionHandler(result)
    }
    
    /// Request to retrieve UI objects for both PAN & Security Code for the provided card id
    func displayPanAndSecurityCode(forCard cardID: String,
                                   panViewConfiguration: PanViewConfiguration,
                                   securityCodeViewConfiguration: SecurityCodeViewConfiguration,
                                   singleUseToken: String,
                                   completionHandler: @escaping ((SecurePropertiesResult) -> Void)) {
        receivedTokens.append(singleUseToken)
        displayCVVReceivedCardIDs.append(cardID)
        displayCVVReceivedDisplayConfigurations.append(securityCodeViewConfiguration)
        
        displayPanReceivedCardIDs.append(cardID)
        displayPanReceivedDisplayConfigurations.append(panViewConfiguration)
        
        guard let result = displayPanAndCVVResult else {
            XCTFail("Method called without setting any completion!")
            return
        }
        completionHandler(result)
    }
    
    func getCards(sessionToken: String,
                  completionHandler: @escaping ((CardListResult) -> Void)) {
        receivedTokens.append(sessionToken)
        getCardsCallCount += 1
        guard let result = getCardsResult else {
            XCTFail("Method called without setting any completion!")
            return
        }
        completionHandler(result)
    }
    
}

