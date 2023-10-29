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
    private let coreDataprovider = CoreDataProvider()
    
    //MARK: - Properties
    var viewState: ((HeroesViewState) -> Void)?
    var heroesCount: Int {
        heroes.count
    }
    
    private var loggedSuccessful: Bool
    private var heroes: HeroesDAO = []
    
    //MARK: - Initializers
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol, loggedSuccessful: Bool) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
        self.loggedSuccessful = loggedSuccessful
    }
    //MARK: - LifeCycle
    
    func onViewAppear() {
        defer { self.viewState?(.loading(false)) }
        self.heroes = coreDataprovider.loadHeroes()
        if self.heroes.count == 0 {
            guard let token = self.secureDataProvider.getToken() else { return }
            self.apiProvider.getHeroes(by: nil, token: token) { [weak self] heroes in
                DispatchQueue.main.async {
                    self?.coreDataprovider.saveHero(heroes: heroes)
                    self?.heroes = self?.coreDataprovider.loadHeroes() ?? []
                    self?.viewState?(.updateData)
                }
            }
        } else {
            self.viewState?(.updateData)
        }
    }
    
    //MARK: - Functions
    func filterHeroesByName(name: String) {
        if name.count == 0 {
            self.heroes = coreDataprovider.loadHeroes()
        } else {
            self.heroes = coreDataprovider.loadHeroesByName(name: name)
        }
        self.viewState?(.updateData)
    }
    
    func heroBy(index: Int) -> HeroDAO? {
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
            secureDataProvider: secureDataProvider)
    }
    
    func heroMapViewModel() -> HeroMapControllerDelegate? {
        return HeroMapViewModel(apiProvider: apiProvider
                                , secureDataProvider: secureDataProvider)
    }
    
    func addObserverErrors() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(apiErrorReceived(notification:)),
                                               name: .apiProviderError,
                                               object: nil)
    }
    
    func removeObserverErrors() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func apiErrorReceived(notification: Notification) {
        guard let object = notification.object,
              let error = object as? ApiProviderError else { return }
        viewState?(.apiError(error.mesaggeError()))
    }
}

