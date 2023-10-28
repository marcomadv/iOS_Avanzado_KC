//
//  ApiProvider.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 13/10/23.
//

import Foundation

enum ApiProviderError: Error {
    case invalidCredentials
    case serverError
    case emptyData
    case decodeFailure
    case statusCode(code: Int)
    case malformedUrl
    
    func mesaggeError() -> String {
        switch self {
        case .invalidCredentials:
            return "Credenciales incorrectas, inténtelo de nuevo"
        case .serverError:
            return "ServerError"
        case .emptyData:
            return "No se pudieron cargar los datos"
        case .decodeFailure:
            return "La decodificación de los datos fue erronea"
        case .statusCode(code: let code):
            return "Se ha producido un error \(code)"
        case .malformedUrl:
            return "Url inválida"
        }
    }
}

extension Notification.Name {
    static let apiProviderError = Notification.Name("NOTIFICATION_API_ERROR")
}

extension NotificationCenter {
    static let apiLoginNotification = Notification.Name("NOTIFICATION_API_LOGIN")
    static let tokenKey = "KEY_TOKEN"
}

protocol ApiProviderProtocol {
    func login(for user: String, with password: String)
    func getHeroes(by name: String?, token: String, completion: ((Heroes) -> Void)?)
    func getLocations(by heroId: String?, token: String, completion: ((HeroLocations) -> Void)?)
}

class ApiProvider: ApiProviderProtocol {
    //MARK: - Constants
    static private let apiBaseURL = "https://dragonball.keepcoding.education/api"
    
    private enum Endpoint {
        static let login = "/auth/login"
        static let heroes = "/heros/all"
        static let heroLocations = "/heros/locations"
    }
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    //MARK: - ApiProviderProtocol
    func login(for user: String, with password: String) {
        //Usamos notificación para devolver el token
        guard let url = URL(string: "\(ApiProvider.apiBaseURL)\(Endpoint.login)") else {
            return
        }
        
        guard let loginData = String(format: "%@:%@", user, password).data(using: .utf8)?.base64EncodedString() else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.serverError)
                return
            }
            
            guard let data, (response as? HTTPURLResponse)?.statusCode == 200 else {
                var object = ApiProviderError.invalidCredentials
                if let statuscode = (response as? HTTPURLResponse)?.statusCode {
                    if statuscode != 401 {
                        object = ApiProviderError.statusCode(code: statuscode)
                    }
                }
                NotificationCenter.default.post(name: .apiProviderError, object: object)
                return
            }
            
            guard let responseData = String(data: data, encoding: .utf8) else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.emptyData)
                return
            }
            
            NotificationCenter.default.post(
                name: NotificationCenter.apiLoginNotification,
                object: nil,
                userInfo:[NotificationCenter.tokenKey: responseData]
            )
        }.resume()
    }
    
    func getHeroes(by name: String?, token: String, completion: ((Heroes) -> Void)?) {
        guard let url = URL(string: "\(ApiProvider.apiBaseURL)\(Endpoint.heroes)") else {
            NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.malformedUrl)
            return
        }
        let jsonData: [String: Any] = ["name": name ?? ""]
        let jsonParameters = try? JSONSerialization.data(withJSONObject: jsonData)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = jsonParameters
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.serverError)
                completion?([])
                return
            }
            
            guard let data, (response as? HTTPURLResponse)?.statusCode == 200 else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.emptyData)
                completion?([])
                return
            }
            do{
                let heroes = try JSONDecoder().decode(Heroes.self, from: data)
                completion?(heroes)
            } catch {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.decodeFailure)
                completion?([])
            }
        }.resume()
    }
    
    func getLocations(by heroId: String?, token: String, completion: ((HeroLocations) -> Void)?) {
        guard let url = URL(string: "\(ApiProvider.apiBaseURL)\(Endpoint.heroLocations)") else {
            NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.malformedUrl)
            return
        }
        
        let jsonData: [String: Any] = ["id": heroId ?? ""]
        let jsonParameters = try? JSONSerialization.data(withJSONObject: jsonData)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8",
                            forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)",
                            forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = jsonParameters
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.serverError)
                completion?([])
                return
            }
            
            guard let data,
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.emptyData)
                completion?([])
                return
            }
            do{
                let heroLocations = try JSONDecoder().decode(HeroLocations.self, from: data)
                completion?(heroLocations)
                
            } catch {
                NotificationCenter.default.post(name: .apiProviderError, object: ApiProviderError.decodeFailure)
                completion?([])
            }
        } .resume()
    }
}

