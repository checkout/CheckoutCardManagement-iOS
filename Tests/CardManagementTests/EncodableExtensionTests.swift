//
//  EncodableExtensionTests.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import XCTest
import CheckoutEventLoggerKit
@testable import CheckoutCardManagement

final class EncodableExtensionTests: XCTestCase {
    
    func testConversionToLogDictionary() {
        let testDictionaryArray = ["info": ["important", "not so much"],
                                   "lost": []]
        let testObject = SampleEncodable(title: "wonderful",
                                         counter: 23,
                                         array: [1, 2, 3, 5, 8, 13],
                                         dictionaryArray: testDictionaryArray)
        let dictionaryObject = try! testObject.mapToLogDictionary()
        XCTAssertEqual(dictionaryObject.count, 4)
        XCTAssertEqual(dictionaryObject["title"]?.value as? String, "wonderful")
        XCTAssertEqual(dictionaryObject["counter"]?.value as? Int, 23)
        XCTAssertEqual(dictionaryObject["array"]?.value as? [Int], [1, 2, 3, 5, 8, 13])
        XCTAssertEqual(dictionaryObject["dictionaryArray"]?.value as? [String: [String]], testDictionaryArray)
        
    }
    
}

struct SampleEncodable: Encodable {
    
    let title: String
    let counter: Int
    let array: [Int]
    let dictionaryArray: [String: [String]]
    
}
