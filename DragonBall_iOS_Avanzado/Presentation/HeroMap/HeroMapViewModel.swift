//
//  HeroMapViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 24/10/23.
//

import Foundation
import CoreData

class HeroMapViewModel: HeroMapControllerDelegate {

    private let coreDataprovider = CoreDataProvider()
    
    
    func onViewDidLoad() {
        let locations = coreDataprovider.loadLocations()
        print("Locations \(locations)")
    }
}
