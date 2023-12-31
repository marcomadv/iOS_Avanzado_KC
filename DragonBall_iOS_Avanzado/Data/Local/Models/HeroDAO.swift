//
//  HeroDAO.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 18/10/23.
//

import Foundation
import CoreData

typealias HeroesDAO = [HeroDAO]

@objc(HeroDAO)
class HeroDAO: NSManagedObject {
    static let entityName = "HeroDAO"
    
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var heroDescription: String?
    @NSManaged var photo: String?
    @NSManaged var favorite: Bool
    @NSManaged var locations: Set <LocationDAO>
}
