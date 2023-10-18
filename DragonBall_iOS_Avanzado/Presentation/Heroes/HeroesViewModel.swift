//
//  HeroesViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 17/10/23.
//

import Foundation


class HeroesViewModel {
    //MARK: - Dependencies
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    
    //MARK: - Properties
    private var heroes: Heroes = []
    
    //MARK: - Initializers
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func onViewAppear() {
        DispatchQueue.global().async {
            guard let token = self.secureDataProvider.getToken() else { return }
            self.apiProvider.getHeroes(by: nil, token: token) { heroes in
                self.heroes = heroes
            }
        }
    }
}
