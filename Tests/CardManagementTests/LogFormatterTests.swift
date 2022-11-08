//
//  LogFormatterTests.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import XCTest
import CheckoutEventLoggerKit
@testable import CheckoutCardManagement

final class LogFormatterTests: XCTestCase {
    
    func testBuildInitializeEvent() {
        let design = CardManagementDesignSystem(font: .systemFont(ofSize: 20), textColor: .red)
        let testEvent = LogEvent.initialized(design: design)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_management_initialised")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        XCTAssertLessThan(Date().timeIntervalSince(formattedEvent.time), 0.1)
        
        let expectedEventProperties = [
            "version": AnyCodable(Constants.productVersion),
            "design": AnyCodable(try! design.mapToLogDictionary())
        ]
        XCTAssertEqual(formattedEvent.properties, expectedEventProperties)
    }
    
    func testBuildCardListEvent() {
        let cardIDs = ["1234", "abcv", "1fd5"]
        let testEvent = LogEvent.cardList(idSuffixes: cardIDs)
        let eventStartDate = Date(timeIntervalSinceNow: -21.123)
        
        let formattedEvent = LogFormatter.build(event: testEvent, startedAt: eventStartDate)
        
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_list")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        XCTAssertLessThan(Date().timeIntervalSince(formattedEvent.time), 0.1)
        
        XCTAssertEqual(formattedEvent.properties.count, 2)
        XCTAssertEqual(formattedEvent.properties["duration"]?.value as? Double, 21.12)
        XCTAssertEqual(formattedEvent.properties["suffix_ids"]?.value as? [String], cardIDs)
    }
    
    func testBuildCardListEventWithoutStartDate() {
        let cardIDs = ["1234", "abcv", "1fd5"]
        let testEvent = LogEvent.cardList(idSuffixes: cardIDs)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_list")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        XCTAssertLessThan(Date().timeIntervalSince(formattedEvent.time), 0.1)
        
        XCTAssertEqual(formattedEvent.properties.count, 1)
        XCTAssertEqual(formattedEvent.properties["suffix_ids"]?.value as? [String], cardIDs)
    }
    
    func testBuildGetPinEvent() {
        let testID = "vbnA"
        let testCardState = CardState.inactive
        let testEvent = LogEvent.getPin(idLast4: testID, cardState: testCardState)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pin")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        
        XCTAssertEqual(formattedEvent.properties.count, 2)
        XCTAssertEqual(formattedEvent.properties["suffix_id"]?.value as? String, testID)
        XCTAssertEqual(formattedEvent.properties["card_state"]?.value as? String, testCardState.rawValue)
    }
    
    func testBuildGetPanEvent() {
        let testID = "sbZ8"
        let testCardState = CardState.active
        let testEvent = LogEvent.getPan(idLast4: testID, cardState: testCardState)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pan")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        
        XCTAssertEqual(formattedEvent.properties.count, 2)
        XCTAssertEqual(formattedEvent.properties["suffix_id"]?.value as? String, testID)
        XCTAssertEqual(formattedEvent.properties["card_state"]?.value as? String, testCardState.rawValue)
    }
    
    func testBuildGetSecurityCodeEvent() {
        let testID = "89aB"
        let testCardState = CardState.revoked
        let testEvent = LogEvent.getCVV(idLast4: testID, cardState: testCardState)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_cvv")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        
        XCTAssertEqual(formattedEvent.properties.count, 2)
        XCTAssertEqual(formattedEvent.properties["suffix_id"]?.value as? String, testID)
        XCTAssertEqual(formattedEvent.properties["card_state"]?.value as? String, testCardState.rawValue)
    }
    
    func testBuildGetPanAndSecurityCodeEvent() {
        let testID = "fB1A"
        let testCardState = CardState.suspended
        let testEvent = LogEvent.getPanCVV(idLast4: testID, cardState: testCardState)
        
        let formattedEvent = LogFormatter.build(event: testEvent)
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_pan_cvv")
        XCTAssertEqual(formattedEvent.monitoringLevel, .info)
        
        XCTAssertEqual(formattedEvent.properties.count, 2)
        XCTAssertEqual(formattedEvent.properties["suffix_id"]?.value as? String, testID)
        XCTAssertEqual(formattedEvent.properties["card_state"]?.value as? String, testCardState.rawValue)
    }
    
    func testBuildFailureEvent() {
        let eventStartDate = Date(timeIntervalSinceNow: -21.13)
        let testEvent = LogEvent.failure(source: "test-case", error: XCTestError(XCTestError.Code.timeoutWhileWaiting))
        let formattedEvent = LogFormatter.build(event: testEvent, startedAt: eventStartDate)
            
        XCTAssertEqual(formattedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.failure")
        XCTAssertEqual(formattedEvent.monitoringLevel, .warn)
        XCTAssertLessThan(Date().timeIntervalSince(formattedEvent.time), 0.1)
        
        XCTAssertEqual(formattedEvent.properties.count, 3)
        XCTAssertEqual(formattedEvent.properties["duration"]?.value as? Double, 21.13)
        XCTAssertEqual(formattedEvent.properties["source"]?.value as? String, "test-case")
        XCTAssertNotNil(formattedEvent.properties["error"]?.value as? String)
    }
}
