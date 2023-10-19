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
                self.deleteAllHeroes()
                self.saveHeroes()
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
    
    func saveHeroes() {
        let moc = CoreDataStack.shared.persistentContainer.viewContext
        let entityHero = NSEntityDescription.entity(forEntityName: HeroDao.entityName, in: moc)
        var heroDAO = HeroDao(entity: entityHero!, insertInto: moc)
        
        for heroes in heroes {
            heroDAO.setValue(heroes.name, forKey: "name")
            heroDAO.setValue(heroes.id, forKey: "id")
            heroDAO.setValue(heroes.description, forKey: "heroDescription")
            heroDAO.setValue(heroes.photo, forKey: "photo")
            heroDAO.setValue(heroes.isFavorite, forKey: "favorite")
        }
        try? moc.save()
    }
    
    func deleteAllHeroes() {
        let moc = CoreDataStack.shared.persistentContainer.viewContext
        let fetchHeroes = NSFetchRequest<HeroDao>(entityName: HeroDao.entityName)
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return }

        heroes.forEach { moc.delete($0) }
        try? moc.save()
    }
}


