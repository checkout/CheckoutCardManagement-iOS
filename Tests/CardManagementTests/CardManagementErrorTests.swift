//
//  CardManagementErrorTests.swift
//  
//
//  Created by Alex Ioja-Yang on 07/06/2022.
//

import XCTest
@testable import CheckoutCardManagement
@testable import CheckoutCardNetwork

class CardManagementErrorTests: XCTestCase {
    
    func testParsingFromUnauthenticated() {
        let testError = CardNetworkError.unauthenticated
        let error = CardManagementError.from(testError)
        XCTAssertEqual(error, .unauthenticated)
    }
    
    func testParsingFromAuthenticationFailure() {
        let testError = CardNetworkError.authenticationFailure
        let error = CardManagementError.from(testError)
        XCTAssertEqual(error, .authenticationFailure)
    }
    
    func testParsingFromServerIssue() {
        let testError = CardNetworkError.serverIssue
        let error = CardManagementError.from(testError)
        XCTAssertEqual(error, .connectionIssue)
    }
    
}
