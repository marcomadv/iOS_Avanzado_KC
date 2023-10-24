//
//  LocationDAO.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 24/10/23.
//

import Foundation
import CoreData

@objc(LocationDAO)
class LocationDAO: NSManagedObject {
    static let entityName = "LocationDAO"
    
    @NSManaged var id: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var date: String?
    @NSManaged var hero: HeroDAO?
}
