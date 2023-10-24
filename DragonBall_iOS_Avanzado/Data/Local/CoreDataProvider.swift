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
        CoreDataStack.shared.persistentContainer.viewContext
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
        }
        
        try? moc.save()
    }
    
    func loadHeroes() -> HeroesDAO {
        let fetchHeroes = NSFetchRequest<HeroDAO>(entityName: HeroDAO.entityName)
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return [] }
        
        return heroes
    }
    
    func deleteAllHeroes() {
        let fetchHeroes = NSFetchRequest<HeroDAO>(entityName: HeroDAO.entityName)
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return }
        heroes.forEach { moc.delete($0) }
        try? moc.save()
    }
    
    func saveLocations(_ locations: [LocationDAO]) {
        guard let moc,
              let entityLocation = NSEntityDescription.entity(forEntityName: LocationDAO.entityName, in: moc) else { return }
        for location in locations {
            let locationDAO = LocationDAO(entity: entityLocation, insertInto: moc)
            locationDAO.id = location.id
            locationDAO.latitude = location.latitude
            locationDAO.longitude = location.longitude
            locationDAO.date = location.date
            locationDAO.hero = location.hero
        }
        
        try? moc.save()
    }
    
    func loadLocations() -> [LocationDAO] {
        let fetchLocations = NSFetchRequest<LocationDAO>(entityName: LocationDAO.entityName)
        guard let moc,
              let locations = try? moc.fetch(fetchLocations) else { return [] }
        
        return locations
    }
    
    func deleteAllLocations() {
        let fetchLocations = NSFetchRequest<LocationDAO>(entityName: LocationDAO.entityName)
        guard let moc,
              let locations = try? moc.fetch(fetchLocations) else { return }
        locations.forEach { moc.delete($0) }
        
        try? moc.save()
    }
}
