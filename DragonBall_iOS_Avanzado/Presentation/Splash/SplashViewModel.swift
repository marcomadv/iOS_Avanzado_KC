//
//  SplashViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 20/10/23.
//

import Foundation

class SplashViewModel: SplashViewControllerDelegate {
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    private let coreDataProvider = CoreDataProvider()
    
    var viewState: ((SplashViewState) -> Void)?
    
    lazy var loginViewModel: LoginViewControllerDelegate = {
        LoginViewModel(apiProvider: apiProvider, secureDataProvider: secureDataProvider)
    }()
    
    lazy var heroesViewModel: HeroesViewControllerDelegate = {
        HeroesViewModel(apiProvider: apiProvider, secureDataProvider: secureDataProvider, loggedSuccessful: true)
    }()
    
    private var isLogged: Bool {
        secureDataProvider.getToken()?.isEmpty == false
    }
    
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func onViewAppear() {
        viewState?(.loading(true))
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            self.isLogged ? self.viewState?(.navigateToHeroes) : self.viewState?(.navigateToLogin)
        }
    }
    
    func clearToken() {
        secureDataProvider.clearToken()
    }
    
    func deleteAllData() {
        coreDataProvider.deleteAllLocations()
        coreDataProvider.deleteAllHeroes()
    }
}
