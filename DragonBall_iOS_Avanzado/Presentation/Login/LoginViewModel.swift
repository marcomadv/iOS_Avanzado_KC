//
//  LoginViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 11/10/23.
//

import Foundation


class LoginViewModel: LoginViewControllerDelegate {
    
    //MARK: - Dependencies
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    
    //MARK: - Properties
    var viewState: ((LoginViewState) -> Void)?
    
    //MARK: - Init
    
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onLoginSuccess),
            name: NotificationCenter.apiLoginNotification,
            object: nil
        )
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Public functions
    func onLoginPressed(email: String?, password: String?) {
        viewState?(.loading(true))
        DispatchQueue.global().async {
            guard self.isValid(email: email) else {
                self.viewState?(.loading(false))
                self.viewState?(.showErrorEmail("Indique un email válido"))
                return
            }
            
            guard self.isValid(password: password) else {
                self.viewState?(.loading(false))
                self.viewState?(.showErrorPassword("Indique un password válido"))
                return
            }
            
            self.doLoginWith(
                email: email ?? "",
                password: password ?? ""
            )
        }
    }
    
    @objc func onLoginSuccess(_ notification: Notification) {
        // TODO: Parsear resultado que vendra en notification.userInfo
    }
    
    
    
    private func isValid(email: String?) -> Bool {
        email?.isEmpty == false && email?.contains("@") ?? false
    }
    
    private func isValid(password: String?) -> Bool {
        password?.isEmpty == false && (password?.count ?? 0) >= 4
    }
    
    private func doLoginWith(email: String, password: String) {
        apiProvider.login(for: email, with: password)
    }
}
