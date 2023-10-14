//
//  ApiProvider.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 13/10/23.
//

import Foundation


extension NotificationCenter {
    static let apiLoginNotification = Notification.Name("NOTIFICATION_API_LOGIN")
    static let tokenKey = "KEY_TOKEN"
}

protocol ApiProviderProtocol {
    func login(for user: String, with password: String)
}

class ApiProvider: ApiProviderProtocol {
    //MARK: - Constants
    static private let apiBaseURL = "https://dragonball.keepcoding.education/api"
    
    private enum Endpoint {
        static let login = "/auth/login"
    }
    
    //MARK: - ApiProviderProtocol
    func login(for user: String, with password: String) {
        // la forma en la que vamos a hacer las consultas es para utilizar un ejemplo de notification center,
        // en ningun caso se hace de esta forma ni es lo mas óptimo, lo lógico seria hacerlo con un completion: + closure
        guard let url = URL(string: "\(ApiProvider.apiBaseURL)\(Endpoint.login)") else {
            return
        }
        
        guard let loginData = String(format: "%@:%@", user, password).data(using: .utf8)?.base64EncodedString() else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Basic \(loginData)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                //TODO: Enviar notificacion indicando el error
                return
            }
            
            guard let data, (response as? HTTPURLResponse)?.statusCode == 200 else {
                //TODO: Enviar notificacion indicando response error
                return
            }
            
            guard let responseData = String(data: data, encoding: .utf8) else {
                //TODO: Enviar notificacion indicando response vacio
                return
            }
            
            NotificationCenter.default.post(
                name: NotificationCenter.apiLoginNotification,
                object: nil,
                userInfo:[NotificationCenter.tokenKey: responseData]
            )
        }.resume()
        
    }
}
