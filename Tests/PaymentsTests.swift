//
//  PaymentsTests.swift
//  Figo
//
//  Created by Christian König on 02.12.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import XCTest
import Figo


class PaymentsTests: BaseTestCaseWithLogin {
    
    
    func testThatRetrieveSecuritiesForAccountYieldsNoErrors() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        
        login() {
            self.figo.retrieveStandingOrdersForAccount("A1182805.4") { result in
                if case .Success(let orders) = result {
                    print("Retrieved \(orders.count) standing orders")
                }
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testSubmitPayment() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        
        var params = CreatePaymentParameters(accountID: "A1182805.4", type: .Transfer, name: "Christian König", amount: 999, purpose: "Test")
        params.bankCode = "66450050"
        params.accountNumber = "66450050"
        
        let pinHandler: PinResponder = { message, accountID in
            print("\(message) (\(accountID))")
            return (pin: "demo", savePin: true)
        }
        
        let challengeHandler: ChallengeResponder = { message, accountID, challenge in
            print("\(message) (\(accountID))")
            print(challenge)
            return "111111"
        }
        
        login() {
            self.figo.createPayment(params) { result in
                switch result {
                case .Success(let payment):
                    
                    self.figo.submitPayment(payment, tanSchemeID: "M1182805.9", pinHandler: pinHandler, challengeHandler: challengeHandler) { result in
                        XCTAssertNil(result.error)
                        expectation.fulfill()
                    }
                    break
                case .Failure(let error):
                    
                    XCTAssertNil(error)
                    expectation.fulfill()
                    break
                }
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }

    
}

