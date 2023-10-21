//
//  CoreDataProvider.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 21/10/23.
//
import UIKit
import CoreData

class CoreDataProvider {
    
    private var moc: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? CoreDataStack)?.persistentContainer.viewContext
    }
    
    func saveHero(heroes: Heroes) {
        guard let moc,
              let entityHero = NSEntityDescription.entity(forEntityName: HeroDAO.entityName, in: moc) else { return }
        for hero in heroes {
            let heroDao = HeroDAO(entity: entityHero, insertInto: moc)
            heroDao.setValue(hero.name, forKey: "name")
            heroDao.setValue(hero.id, forKey: "id")
            heroDao.setValue(hero.description, forKeyPath: "heroDescription")
            heroDao.setValue(hero.photo, forKey: "photo")
            heroDao.setValue(hero.isFavorite, forKey: "favorite")
            try? moc.save()
        }
    }
    
    func loadHeroes() {
        let fetchHeroes = NSFetchRequest<HeroDAO>(entityName: HeroDAO.entityName)
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return }
        
        print("Heroes: \(heroes)")
    }
    
    func deleteAllHeroes() {
        let fetchHeroes = NSFetchRequest<HeroDAO>(entityName: HeroDAO.entityName)
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return }
        heroes.forEach { moc.delete($0) }
        try? moc.save()
    }
}
