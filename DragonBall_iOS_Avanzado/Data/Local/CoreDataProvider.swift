//
//  CoreDataProvider.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 21/10/23.
//
import UIKit
import CoreData

class CoreDataProvider {
    
    private lazy var moc: NSManagedObjectContext? = {
        let viewContext = CoreDataStack.shared.persistentContainer.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()
    
    var fetchHeroes: NSFetchRequest<HeroDAO> {
        NSFetchRequest<HeroDAO>(entityName: HeroDAO.entityName)
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
        let request = fetchHeroes
        request.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
        guard let moc,
              let heroes = try? moc.fetch(request) else { return [] }
        return heroes
    }
    
    func deleteAllHeroes() {
        guard let moc,
              let heroes = try? moc.fetch(fetchHeroes) else { return }
        heroes.forEach { moc.delete($0) }
        
        saveChanges()
    }
    
     func getHerowith(id: String?) -> HeroDAO? {
        guard let idHero = id,
              let moc else { return nil }
         let request = fetchHeroes
         request.predicate = NSPredicate(format: "id = %@", idHero)
        return try? moc.fetch(request).first
    }
    
    func saveLocations(_ locations: HeroLocations) {
        guard let moc,
              let entityLocation = NSEntityDescription.entity(forEntityName: LocationDAO.entityName, in: moc) else { return }
        for location in locations {
              if let hero = getHerowith(id: location.hero?.id) {
                let locationDAO = LocationDAO(entity: entityLocation, insertInto: moc)
                locationDAO.id = location.id
                locationDAO.latitude = location.latitude
                locationDAO.longitude = location.longitude
                locationDAO.date = location.date
                locationDAO.hero = hero
            }
        }
        saveChanges()
    }
    
    func loadLocations() -> [LocationDAO] {
        let fetchLocations = NSFetchRequest<LocationDAO>(entityName: LocationDAO.entityName)
        guard let moc,
              let locations = try? moc.fetch(fetchLocations) else { return [] }
        return locations
    }
    
    func deleteAllLocations() {
        CoreDataStack.shared.saveContext()
        let fetchLocations = NSFetchRequest<LocationDAO>(entityName: LocationDAO.entityName)
        guard let moc,
              let locations = try? moc.fetch(fetchLocations) else { return }
        locations.forEach { moc.delete($0) }
        saveChanges()
    }
        
        
    private func saveChanges() {
        do{
            try moc?.save() }
        catch {
            debugPrint(error.localizedDescription)
        }
    }
}
