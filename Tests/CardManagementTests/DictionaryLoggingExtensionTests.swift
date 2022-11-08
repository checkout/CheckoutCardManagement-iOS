//
//  DictionaryLoggingExtensionTests.swift
//  
//
//  Created by Alex Ioja-Yang on 20/09/2022.
//

import XCTest
import CheckoutEventLoggerKit
@testable import CheckoutCardManagement

final class DictionaryLoggingExtensionTests: XCTestCase {
    
    func testAddTimeSinceNil() {
        var dictionary = [String: AnyCodable]()
        dictionary.addTimeSince(startDate: nil)
        
        XCTAssertEqual(dictionary, [:])
    }
    
    func testAddTimeSinceValidDate() {
        var dictionary = [String: AnyCodable]()
        dictionary.addTimeSince(startDate: Date(timeIntervalSinceNow: -60.12345))
        
        XCTAssertEqual(dictionary, ["duration": AnyCodable(60.12)])
    }
    
}
