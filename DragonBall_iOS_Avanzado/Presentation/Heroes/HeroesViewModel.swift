//
//  HeroesViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 17/10/23.
//

import Foundation
import CoreData


class HeroesViewModel: HeroesViewControllerDelegate {
    //MARK: - Dependencies
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    
    //MARK: - Properties
    var viewState: ((HeroesViewState) -> Void)?
    var heroesCount: Int {
        heroes.count
    }
    
    private var heroes: Heroes = []
    //MARK: - Initializers
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func onViewAppear() {
        viewState?(.loading(true))
        
        DispatchQueue.global().async {
            defer { self.viewState?(.loading(false)) }
            guard let token = self.secureDataProvider.getToken() else { return }
            
            self.apiProvider.getHeroes(by: nil, token: token) { heroes in
                self.heroes = heroes
                self.viewState?(.updateData)
                DispatchQueue.main.async {
                    let coreDataprovider = CoreDataProvider()
                    for hero in heroes {
                        coreDataprovider.saveHero(heroes: [hero])
                    }
                }
                
//                self.saveHeroes()
                
                //self.deleteAllHeroes()
            }
        }
    }
    
    func heroBy(index: Int) -> Hero? {
        if index >= 0 && index < heroesCount {
            return heroes[index]
        } else {
            return nil
        }
    }
    
    func heroDetailViewModel(index: Int) -> HeroDetailViewControllerDelegate? {
        guard let selectedHero = heroBy(index: index) else { return nil }
        
        return HeroDetailViewModel(
            hero: selectedHero,
            apiProvider: apiProvider,
            secureDataProvider: secureDataProvider
        )
    }
}
