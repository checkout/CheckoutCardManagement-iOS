//
//  UIFontExtensionTests.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import XCTest
import UIKit
@testable import CheckoutCardManagement

final class UIFontExtensionTests: XCTestCase {
    
    func testEncoding() {
        let testFont = UIFont(name: "ZapfDingbatsITC", size: 24)
        let encoded = try! JSONEncoder().encode(testFont)
        let decoded = try! JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        
        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded["name"] as! String, "ZapfDingbatsITC")
        XCTAssertEqual(decoded["weight"] as! String, "Regular")
        XCTAssertEqual(decoded["size"] as! Int, 24)
    }
    
}
