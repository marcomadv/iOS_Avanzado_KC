//
//  DragonBall_iOS_AvanzadoTests.swift
//  DragonBall_iOS_AvanzadoTests
//
//  Created by Marco Muñoz on 11/10/23.
//

import XCTest
@testable import DragonBall_iOS_Avanzado

final class ApiProviderTest: XCTestCase {
    
    private var sut: ApiProvider!
    private let expectedToken = "Some Token"
    private let url = URL(string: "https://dragonball.keepcoding.education/api")!
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        sut = ApiProvider(session: session)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testLogin() {
        let loginUsername = "Some login"
        let loginPassword = "Some password"
        MockURLProtocol.requestHandler = { request in
            let loginString = String(format: "%@:%@", loginUsername,loginPassword)
            let loginData = loginString.data(using: .utf8)!
            let base64LoginString = loginData.base64EncodedString()
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Basic \(base64LoginString)")
            
            let data = try XCTUnwrap(self.expectedToken.data(using: .utf8))
            let response = try XCTUnwrap( self.urlResponseTest())
            
            return (response, data)
        }
        
        let expectation = expectation(forNotification: NotificationCenter.apiLoginNotification,
                                      object: nil) { notification in
            let token = notification.userInfo?[NotificationCenter.tokenKey] as? String
            XCTAssertNotNil(token)
            XCTAssertEqual(token, self.expectedToken)
            return true
        }
        sut.login(for: loginUsername, with: loginPassword)
        wait(for: [expectation], timeout: 1)
    }
    
    func testHeroes() {
        let numHeroes = 16
        let heroeExpected = Hero(id: "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3",
                                 name: "Maestro Roshi",
                                 description: "Es un maestro de artes marciales que tiene una escuela, donde entrenará a Goku y Krilin para los Torneos de Artes Marciales. Aún en los primeros episodios había un toque de tradición y disciplina, muy bien representada por el maestro. Pero Muten Roshi es un anciano extremadamente pervertido con las chicas jóvenes, una actitud que se utilizaba en escenas divertidas en los años 80. En su faceta de experto en artes marciales, fue quien le enseñó a Goku técnicas como el Kame Hame Ha",
                                 photo: "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/Roshi.jpg?width=300",
                                 isFavorite: false)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual("POST", request.httpMethod)
            let heroesUrl = self.url.appendingPathComponent("heros/all")
            XCTAssertEqual(heroesUrl, request.url)
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer \(self.expectedToken)")
            
            let path = Bundle(for: type(of: self)).path(forResource: "heroes", ofType: "json")
            XCTAssertNotNil(path)
            let url = URL.init(filePath: path!)
            let data = try? Data.init(contentsOf: url)
            XCTAssertNotNil(data)
            let response = try XCTUnwrap( self.urlResponseTest())
            return (response, data!)
        }
        
        let expectation = expectation(description: "Se han obtenido los heroes")
        sut.getHeroes(by: "", token: expectedToken) { heroes in
            XCTAssertEqual(heroes.count, numHeroes)
            XCTAssertEqual(heroes.first?.id, heroeExpected.id)
            XCTAssertEqual(heroes.first?.name, heroeExpected.name)
            XCTAssertEqual(heroes.first?.description, heroeExpected.description)
            XCTAssertEqual(heroes.first?.photo, heroeExpected.photo)
            XCTAssertEqual(heroes.first?.isFavorite, heroeExpected.isFavorite)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testGetLocations() {
        let idHero = "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3"
        let hero = Hero(id: "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3",
                        name: nil,
                        description: nil,
                        photo: nil,
                        isFavorite: false)
        let numLocations = 2
        let locationExpected = HeroLocation(id: "AB3A873C-37B4-4FDE-A50F-8014D40D94FE",
                                             latitude: "36.8415268",
                                             longitude: "-2.4746262",
                                             date: "2022-09-11T00:00:00Z",
                                             hero: hero)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual("POST", request.httpMethod)
            let locationsUrl = self.url.appendingPathComponent("heros/locations")
            XCTAssertEqual(locationsUrl, request.url)
            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer \(self.expectedToken)")
            
            let path = Bundle(for: type(of: self)).path(forResource: "locations", ofType: "json")
            XCTAssertNotNil(path)
            let url = URL.init(filePath: path!)
            let data = try? Data.init(contentsOf: url)
            XCTAssertNotNil(data)
            let response = try XCTUnwrap( self.urlResponseTest())
            return (response, data!)
        }
        let expectation = expectation(description: "Se han obtenido las localizaciones para el ID del heroe")
        sut.getLocations(by: idHero, token: expectedToken) { locations in
              XCTAssertEqual(locations.count, numLocations)
            XCTAssertEqual(locations.first?.id, locationExpected.id)
            XCTAssertEqual(locations.first?.latitude, locationExpected.latitude)
            XCTAssertEqual(locations.first?.longitude, locationExpected.longitude)
            XCTAssertEqual(locations.first?.date, locationExpected.date)
            XCTAssertEqual(locations.first?.hero?.id, hero.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    private func urlResponseTest() -> HTTPURLResponse? {
        HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
    }
    
}
