//
//  CheckoutEventLoggingExtensionTests.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import XCTest
@testable import CheckoutCardManagement
@testable import CheckoutEventLoggerKit

final class CheckoutEventLoggingExtensionTests: XCTestCase {
    
    func testLog() {
        let fakeLogger = MockLogger()
        XCTAssertTrue(fakeLogger.receivedLogEvents.isEmpty)
        
        let testEvent = LogEvent.cardList(idSuffixes: [])
        fakeLogger.log(testEvent)
        
        XCTAssertEqual(fakeLogger.receivedLogEvents.count, 1)
        
        let expectedEvent = LogFormatter.build(event: testEvent)
        let receivedEvent = fakeLogger.receivedLogEvents[0]
        XCTAssertEqual(expectedEvent.typeIdentifier, receivedEvent.typeIdentifier)
        XCTAssertEqual(expectedEvent.monitoringLevel, receivedEvent.monitoringLevel)
        XCTAssertEqual(expectedEvent.properties, receivedEvent.properties)
        
        // Expected event is created after the logger flow, so we expect a minimal time difference to exist
        //   which is why events cannot be equal
        XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
    }
    
    func testLogWithStart() {
        let startDate = Date(timeIntervalSinceNow: -10)
        let fakeLogger = MockLogger()
        XCTAssertTrue(fakeLogger.receivedLogEvents.isEmpty)
        
        let testEvent = LogEvent.cardList(idSuffixes: [])
        fakeLogger.log(testEvent, startedAt: startDate)
        
        XCTAssertEqual(fakeLogger.receivedLogEvents.count, 1)
        
        let receivedEvent = fakeLogger.receivedLogEvents[0]
        XCTAssertEqual(receivedEvent.typeIdentifier, "com.checkout.issuing-mobile-sdk.card_list")
        XCTAssertEqual(receivedEvent.monitoringLevel, .info)
        XCTAssertEqual(receivedEvent.properties.count, 2)
        XCTAssertEqual(receivedEvent.properties["duration"]?.value as? Double, 10.0)
        XCTAssertEqual(receivedEvent.properties["suffix_ids"]?.value as? [String], [])
        
        // Expected event is created after the logger flow, so we expect a minimal time difference to exist
        //   which is why events cannot be equal
        XCTAssertLessThan(Date().timeIntervalSince(receivedEvent.time), 0.1)
    }
}
