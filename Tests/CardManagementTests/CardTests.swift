//
//  CardTests.swift
//
//
//  Created by Alex Ioja-Yang on 09/06/2022.
//

import XCTest
@testable import CheckoutCardNetwork
@testable import CheckoutCardManagement

class CardTests: XCTestCase {

    func testParsingFromNetwork() {
        let networkExpiryDate = CheckoutCardNetwork.CardExpiryDate(month: "12", year: "4321")
        let networkCard = CheckoutCardNetwork.Card(id: "1ABc35",
                                                          displayName: "Johny",
                                                          panLast4Digits: "1234",
                                                          state: .inactive,
                                                          expiryDate: networkExpiryDate)
        let mockManager = MockCardManager()
        let card = CheckoutCardManagement.Card(networkCard: networkCard,
                                               manager: mockManager)

        XCTAssertEqual(card.panLast4Digits, networkCard.panLast4Digits)
        XCTAssertEqual(card.expiryDate.month, networkCard.expiryDate.month)
        XCTAssertEqual(card.expiryDate.year, networkCard.expiryDate.year)
        XCTAssertEqual(card.cardHolderName, networkCard.displayName)
        XCTAssertTrue(card.manager === mockManager)
    }

    // MARK: Pin
    func testDisplayPinSuccess() {
        let testView = UIView()
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPinResult = .success(testView)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPin(singleUseToken: "") { result in
            XCTAssertEqual(result, .success(testView))
            XCTAssertEqual(mockClient.displayPinReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPinReceivedDisplayConfigurations, [mockManager.designSystem.pinViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPinFailure() {
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPinResult = .failure(.authenticationFailure)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPin(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.authenticationFailure))
            XCTAssertEqual(mockClient.displayPinReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPinReceivedDisplayConfigurations, [mockManager.designSystem.pinViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPinNoManager() {
        let testCard = Card(id: "1234ABC",
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: nil)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPin(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.missingManager))
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    // MARK: Pan
    func testDisplayPanSuccess() {
        let testView = UIView()
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPanResult = .success(testView)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPan(singleUseToken: "") { result in
            XCTAssertEqual(result, .success(testView))
            XCTAssertEqual(mockClient.displayPanReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPanReceivedDisplayConfigurations, [mockManager.designSystem.panViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPanFailure() {
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPanResult = .failure(.authenticationFailure)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPan(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.authenticationFailure))
            XCTAssertEqual(mockClient.displayPanReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPanReceivedDisplayConfigurations, [mockManager.designSystem.panViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPanNoManager() {
        let testCard = Card(id: "1234ABC",
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: nil)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPan(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.missingManager))
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: SecurityCode
    func testDisplaySecurityCodeSuccess() {
        let testView = UIView()
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayCVVResult = .success(testView)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getSecurityCode(singleUseToken: "") { result in
            XCTAssertEqual(result, .success(testView))
            XCTAssertEqual(mockClient.displayCVVReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayCVVReceivedDisplayConfigurations, [mockManager.designSystem.securityCodeViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplaySecurityCodeFailure() {
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayCVVResult = .failure(.authenticationFailure)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getSecurityCode(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.authenticationFailure))
            XCTAssertEqual(mockClient.displayCVVReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayCVVReceivedDisplayConfigurations, [mockManager.designSystem.securityCodeViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplaySecurityCodeNoManager() {
        let testCard = Card(id: "1234ABC",
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: nil)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getSecurityCode(singleUseToken: "") { result in
            XCTAssertEqual(result, .failure(.missingManager))
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Pan + SecurityCode
    func testDisplayPanAndSecurityCodeSuccess() {
        let testViewPAN = UIView()
        let testViewCVV = UIView()
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPanAndCVVResult = .success((pan: testViewPAN, securityCode: testViewCVV))
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPanAndSecurityCode(singleUseToken: "") { result in
            if case .success(let secureViews) = result {
                XCTAssertTrue(secureViews.pan === testViewPAN)
                XCTAssertTrue(secureViews.securityCode === testViewCVV)
            } else {
                XCTFail("Unexpected outcome for test")
            }
            XCTAssertEqual(mockClient.displayPanReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPanReceivedDisplayConfigurations, [mockManager.designSystem.panViewDesign])
            XCTAssertEqual(mockClient.displayCVVReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayCVVReceivedDisplayConfigurations, [mockManager.designSystem.securityCodeViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPanAndSecurityCodeFailure() {
        let testCardNumber = "1234ABC"
        let mockClient = MockCardService()
        mockClient.displayPanAndCVVResult = .failure(.authenticationFailure)
        let mockManager = MockCardManager()
        mockManager.cardService = mockClient

        let testCard = Card(id: testCardNumber,
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: mockManager)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPanAndSecurityCode(singleUseToken: "") { result in
            if case .failure(let failure) = result {
                XCTAssertEqual(failure, .authenticationFailure)
            } else {
                XCTFail("Unexpected outcome for test")
            }
            XCTAssertEqual(mockClient.displayPanReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayPanReceivedDisplayConfigurations, [mockManager.designSystem.panViewDesign])
            XCTAssertEqual(mockClient.displayCVVReceivedCardIDs, [testCardNumber])
            XCTAssertEqual(mockClient.displayCVVReceivedDisplayConfigurations, [mockManager.designSystem.securityCodeViewDesign])
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

    func testDisplayPanAndSecurityCodeNoManager() {
        let testCard = Card(id: "1234ABC",
                            panLast4Digits: "0001",
                            expiryDate: CardExpiryDate(month: "11", year: "2021"),
                            cardHolderName: "owner",
                            manager: nil)

        let expect = expectation(description: "Wait for threaded response")
        testCard.getPanAndSecurityCode(singleUseToken: "") { result in
            if case .failure(let failure) = result {
                XCTAssertEqual(failure, .missingManager)
            } else {
                XCTFail("Unexpected outcome for test")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Analytics
    func testGetPanSuccessTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPanResult = .success(UIView())
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPan(singleUseToken: "") { result in
            expect.fulfill()
            if case .success(_) = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .info)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pan")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 0.0)
                XCTAssertEqual(receivedEvent.properties["suffix_id"]?.value as? String, testCard.partIdentifier)
                XCTAssertEqual(receivedEvent.properties["card_state"]?.value as? String, CardState.inactive.rawValue)
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetPanFailureTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPanResult = .failure(.unauthenticated)
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPan(singleUseToken: "") { result in
            expect.fulfill()
            if case .failure = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .warn)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertLessThan(receivedEvent.properties["duration"]?.value as! Double, 0.2)
                XCTAssertEqual(receivedEvent.properties["source"]?.value as? String, "Get Pan")
                XCTAssertEqual(receivedEvent.properties["error"]?.value as? String, "The operation couldn’t be completed. (CheckoutCardNetwork.CardNetworkError error 7.)")
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetPanAndSecurityCodeSuccessTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPanAndCVVResult = .success((pan: UIView(), securityCode: UIView()))
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPanAndSecurityCode(singleUseToken: "") { result in
            expect.fulfill()
            if case .success(_) = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .info)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pan_cvv")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 0.0)
                XCTAssertEqual(receivedEvent.properties["suffix_id"]?.value as? String, testCard.partIdentifier)
                XCTAssertEqual(receivedEvent.properties["card_state"]?.value as? String, CardState.inactive.rawValue)
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetPanAndSecurityCodeFailureTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPanAndCVVResult = .failure(.unauthenticated)
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPanAndSecurityCode(singleUseToken: "") { result in
            expect.fulfill()
            if case .failure = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .warn)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertLessThan(receivedEvent.properties["duration"]?.value as! Double, 0.2)
                XCTAssertEqual(receivedEvent.properties["source"]?.value as? String, "Get Pan and SecurityCode")
                XCTAssertEqual(receivedEvent.properties["error"]?.value as? String, "The operation couldn’t be completed. (CheckoutCardNetwork.CardNetworkError error 7.)")
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testGetPinSuccessTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPinResult = .success(UIView())
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPin(singleUseToken: "") { result in
            expect.fulfill()
            if case .success(_) = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .info)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pin")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 0.0)
                XCTAssertEqual(receivedEvent.properties["suffix_id"]?.value as? String, testCard.partIdentifier)
                XCTAssertEqual(receivedEvent.properties["card_state"]?.value as? String, CardState.inactive.rawValue)
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetPinFailureTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayPinResult = .failure(.unauthenticated)
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getPin(singleUseToken: "") { result in
            expect.fulfill()
            if case .failure = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .warn)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertLessThan(receivedEvent.properties["duration"]?.value as! Double, 0.2)
                XCTAssertEqual(receivedEvent.properties["source"]?.value as? String, "Get Pin")
                XCTAssertEqual(receivedEvent.properties["error"]?.value as? String, "The operation couldn’t be completed. (CheckoutCardNetwork.CardNetworkError error 7.)")
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetSecurityCodeSuccessTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayCVVResult = .success(UIView())
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getSecurityCode(singleUseToken: "") { result in
            expect.fulfill()
            if case .success(_) = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .info)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_cvv")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 0.0)
                XCTAssertEqual(receivedEvent.properties["suffix_id"]?.value as? String, testCard.partIdentifier)
                XCTAssertEqual(receivedEvent.properties["card_state"]?.value as? String, CardState.inactive.rawValue)
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetSecurityCodeFailureTriggersAnalyticsEvent() {
        let testCardID = "123456789A"
        let mockLogger = MockLogger()
        let mockClient = MockCardService()
        mockClient.displayCVVResult = .failure(.unauthenticated)
        let mockManager = MockCardManager()
        mockManager.logger = mockLogger
        mockManager.cardService = mockClient
        let testCard = Card(id: testCardID,
                            panLast4Digits: "0000",
                            expiryDate: CardExpiryDate(month: "11", year: "2033"),
                            cardHolderName: "owner",
                            manager: mockManager)
        
        let expect = expectation(description: "Ensure completion is called")
        testCard.getSecurityCode(singleUseToken: "") { result in
            expect.fulfill()
            if case .failure = result {
                XCTAssertEqual(mockLogger.receivedLogEvents.count, 1)
                
                let receivedEvent = mockLogger.receivedLogEvents[0]
                XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
                XCTAssertEqual(receivedEvent.monitoringLevel, .warn)
                XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
                XCTAssertEqual(receivedEvent.properties.count, 3)
                XCTAssertLessThan(receivedEvent.properties["duration"]?.value as! Double, 0.2)
                XCTAssertEqual(receivedEvent.properties["source"]?.value as? String, "Get Security Code")
                XCTAssertEqual(receivedEvent.properties["error"]?.value as? String, "The operation couldn’t be completed. (CheckoutCardNetwork.CardNetworkError error 7.)")
            } else {
                XCTFail("Unexpected outcome for test")
            }
        }
        waitForExpectations(timeout: 1)
    }
}
