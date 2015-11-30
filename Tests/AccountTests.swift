//
//  Figo_iOS_Tests.swift
//  Figo iOS Tests
//
//  Created by Christian König on 20.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import XCTest
import Figo


class AccountTests: BaseTestCaseWithLogin {
    
    let demoBankCode = "90090042"
    let demoCredentials = ["demo", "demo"]
    
    func testShowsSimplestRetrieveAccountsCallWithoutErrorHandling() {
        
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            self.figo.retrieveAccounts() { result in
                if let accounts = result.value {
                    XCTAssertGreaterThan(accounts.count, 0)
                }
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }

        self.waitForExpectationsWithTimeout(30, handler: nil)

    }
    
    func testThatRetrieveAccountsYieldsObjects() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            self.figo.retrieveAccounts() { result in
                if let accounts = result.value {
                    XCTAssertGreaterThan(accounts.count, 0)
                }
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testThatRetrieveAccountYieldsObject() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            self.figo.retrieveAccount("A1182805.2") { result in
                XCTAssertNil(result.error)
                if let account = result.value {
                    XCTAssertEqual(account.account_number, "4711951501")

                }
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testRemovePin() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            self.figo.removeStoredPinFromBankContact("B1182805.1") { result in
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func xtestSetupAccount() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            let account = CreateAccountParameters(bank_code: self.demoBankCode, iban: nil, credentials: self.demoCredentials, save_pin: true, disable_first_sync: nil, sync_tasks: nil)
            self.figo.setupNewBankAccount(account) { result in
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func xtestDeleteBankAccount() {
        let expectation = self.expectationWithDescription("Wait for all asyc calls to return")
        login() {
            self.figo.deleteAccount("A1182805.1") { result in
                XCTAssertNil(result.error)
                expectation.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    

}