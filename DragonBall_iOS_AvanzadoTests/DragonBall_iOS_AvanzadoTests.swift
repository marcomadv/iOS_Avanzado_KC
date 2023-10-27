//
//  DragonBall_iOS_AvanzadoTests.swift
//  DragonBall_iOS_AvanzadoTests
//
//  Created by Marco Muñoz on 11/10/23.
//

import XCTest
@testable import DragonBall_iOS_Avanzado

final class DragonBall_iOS_AvanzadoTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCaseGetHeroesReal() throws {
        let apiProvider = ApiProvider()
        let secureDataProvider = SecureDataProvider()
        guard let token = secureDataProvider.getToken() else { return }
        
        apiProvider.getHeroes(by: nil, token: token) { heroes in
            XCTAssertNotNil(heroes)
        }
    }
    
    func testCaseGetLocationsReal() throws {
        let apiProvider = ApiProvider()
        let secureDataProvider = SecureDataProvider()
        guard let token = secureDataProvider.getToken() else { return }
        
        apiProvider.getLocations(by: nil, token: token) { locations in
            XCTAssertNotNil(locations)
        }
    }
}
