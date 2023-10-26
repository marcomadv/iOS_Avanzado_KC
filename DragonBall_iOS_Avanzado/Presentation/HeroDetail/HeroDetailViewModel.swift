//
//  HeroDetailViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 20/10/23.
//

import Foundation

class HeroDetailViewModel: HeroDetailViewControllerDelegate {
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    
    private let coreDataProvider = CoreDataProvider()
    
    var viewState: ((HeroDetailViewState) -> Void)?
    private var hero: HeroDAO
    private var heroLocations: [LocationDAO] = []
    
    init(hero: HeroDAO, apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.hero = hero
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    func onViewAppear() {
        defer { self.viewState?(.loading(false)) }
        viewState?(.loading(true))
        if self.hero.locations.count == 0 {
            guard let token = self.secureDataProvider.getToken() else { return }
            self.apiProvider.getLocations(by: self.hero.id, token: token) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.coreDataProvider.saveLocations(locations)
                    self?.heroLocations = Array(self?.hero.locations ?? [])
                    self?.viewState?(.update(hero: self?.hero, locations: self?.heroLocations))
                }
            }
        } else {
            self.heroLocations = Array(self.hero.locations)
            self.viewState?(.update(hero: self.hero, locations: self.heroLocations))
        }
    }
}

