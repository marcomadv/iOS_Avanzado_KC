//
//  SecureDataProviderTest.swift
//  DragonBall_iOS_AvanzadoTests
//
//  Created by Marco Muñoz on 28/10/23.
//

import XCTest
@testable import DragonBall_iOS_Avanzado

class SecureDataProviderTest: XCTestCase {
    var sut: SecureDataProviderProtocol!
    let someToken = "token"
    
    override func setUp() {
        super.setUp()
        sut = SecureDataProvider()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testSave () {
        sut.save(token: someToken)
        var token = sut.getToken()
        XCTAssertNotNil(token)
        XCTAssertEqual(token, someToken)
    }
    
    func testClearToken() {
        sut.save(token: someToken)
        var token = sut.getToken()
        XCTAssertNotNil(token)
        sut.clearToken()
        token = sut.getToken()
        XCTAssertNil(token)
        
    }
}
