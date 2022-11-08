//
//  CheckoutCardManagerTests.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import XCTest
@testable import CheckoutCardNetwork
@testable import CheckoutCardManagement

class CheckoutCardManagerTests: XCTestCase {
    
    func testInitialiser() {
        let testDesign = makeDesignSystem()
        let manager = CheckoutCardManager(designSystem: testDesign,
                                          environment: .sandbox)
        
        XCTAssertEqual(manager.designSystem, testDesign)
        XCTAssertTrue(manager.cardService is CheckoutCardService)
    }
    
    func testGetCardsUnauthenticated() {
        let mockClient = MockCardService()
        let testCards = [
            CheckoutCardNetwork.Card(id: "1", cardholderID: "", displayName: "1", panLast4Digits: "", state: .suspended, reference: "", type: .physical, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "01", year: "43")),
            CheckoutCardNetwork.Card(id: "3", cardholderID: "", displayName: "3", panLast4Digits: "", state: .active, reference: "", type: .virtual, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "11", year: "48"))
        ]
        mockClient.getCardsResult = .success(testCards)
        let manager = CheckoutCardManager(service: mockClient, designSystem: makeDesignSystem())
        
        let expect = expectation(description: "Wait for response")
        manager.getCards() { result in
            expect.fulfill()
            XCTAssertEqual(result, .failure(.unauthenticated))
            XCTAssertEqual(mockClient.getCardsCallCount, 0)
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testGetCardsSuccess() {
        let mockClient = MockCardService()
        let testCards = [
            CheckoutCardNetwork.Card(id: "1", cardholderID: "", displayName: "1", panLast4Digits: "", state: .suspended, reference: "", type: .physical, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "01", year: "43")),
            CheckoutCardNetwork.Card(id: "3", cardholderID: "", displayName: "3", panLast4Digits: "", state: .active, reference: "", type: .virtual, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "11", year: "48"))
        ]
        mockClient.getCardsResult = .success(testCards)
        let manager = CheckoutCardManager(service: mockClient, designSystem: makeDesignSystem())
        manager.logInSession(token: "")
        
        let expect = expectation(description: "Wait for response")
        manager.getCards() { result in
            expect.fulfill()
            let expectedCards = testCards.compactMap { Card(networkCard: $0, manager: manager) }
            XCTAssertEqual(result, .success(expectedCards))
            XCTAssertEqual(mockClient.getCardsCallCount, 1)
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testGetCardsFailure() {
        let mockClient = MockCardService()
        mockClient.getCardsResult = .failure(.serverIssue)
        let manager = CheckoutCardManager(service: mockClient, designSystem: makeDesignSystem())
        manager.logInSession(token: "")
        
        let expect = expectation(description: "Wait for response")
        manager.getCards() { result in
            expect.fulfill()
            XCTAssertEqual(result, .failure(.connectionIssue))
            XCTAssertEqual(mockClient.getCardsCallCount, 1)
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Analytics
    func testGetCardsSuccessAnalyticsEvent() {
        let testCards = [
            CheckoutCardNetwork.Card(id: "1sdg876tyafiu6", cardholderID: "", displayName: "1", panLast4Digits: "", state: .suspended, reference: "", type: .physical, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "01", year: "43")),
            CheckoutCardNetwork.Card(id: "3advdthtrh", cardholderID: "", displayName: "3", panLast4Digits: "", state: .active, reference: "", type: .virtual, createdOn: Date(), lastModifiedOn: Date(), expiryDate: .init(month: "11", year: "48"))
        ]
        let mockClient = MockCardService()
        mockClient.getCardsResult = .success(testCards)
        
        let mockLogger = MockLogger()
        let manager = CheckoutCardManager(service: mockClient, designSystem: makeDesignSystem(), logger: mockLogger)
        manager.logInSession(token: "")
        
        let expect = expectation(description: "Wait for threaded response")
        manager.getCards() { result in
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 0.1)
        
        // Includes init
        XCTAssertEqual(mockLogger.receivedLogEvents.count, 2)
        
        let receivedEvent = mockLogger.receivedLogEvents[1]
        XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
        XCTAssertEqual(receivedEvent.monitoringLevel, .info)
        XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_list")
        XCTAssertEqual(receivedEvent.properties.count, 2)
        XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 0.0)
        XCTAssertEqual(receivedEvent.properties["suffix_ids"]?.value as? [String], ["fiu6", "htrh"])
    }
    
    func testGetCardsFailureAnalyticsEvent() {
        let mockClient = MockCardService()
        mockClient.getCardsResult = .failure(.deviceNotSupported)
        
        let mockLogger = MockLogger()
        let manager = CheckoutCardManager(service: mockClient, designSystem: makeDesignSystem(), logger: mockLogger)
        manager.logInSession(token: "")
        
        let expect = expectation(description: "Wait for threaded response")
        manager.getCards() { result in
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 0.1)
        
        // Includes init
        XCTAssertEqual(mockLogger.receivedLogEvents.count, 2)
        
        let receivedEvent = mockLogger.receivedLogEvents[1]
        XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
        XCTAssertEqual(receivedEvent.monitoringLevel, .warn)
        XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
        XCTAssertEqual(receivedEvent.properties.count, 3)
        XCTAssertLessThan(receivedEvent.properties["duration"]?.value as! Double, 0.2)
        XCTAssertEqual(receivedEvent.properties["source"]?.value as? String, "Get Cards")
        XCTAssertEqual(receivedEvent.properties["error"]?.value as? String, "The operation couldn’t be completed. (CheckoutCardNetwork.CardNetworkError error 3.)")
    }
    
    private func makeDesignSystem() -> CardManagementDesignSystem {
        CardManagementDesignSystem(font: .boldSystemFont(ofSize: CGFloat(Int.random(in: 10...30))),
                                   textColor: [UIColor.orange, .white, .blue, .brown, .green, .cyan].randomElement()!)
    }
    
}
