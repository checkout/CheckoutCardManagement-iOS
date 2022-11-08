//
//  UIColorExtensionTests.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import XCTest
import UIKit
@testable import CheckoutCardManagement

final class UIColorExtensionTests: XCTestCase {
    
    func testEncoding() {
        let color = UIColor.blue.withAlphaComponent(0.7)
        let encoded = try! JSONEncoder().encode(color)
        let decoded = try! JSONSerialization.jsonObject(with: encoded) as! [String: String]
        
        XCTAssertEqual(decoded, ["hex": "#0000FFB3"])
    }
    
}
