//
//  HeroMapViewModel.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 24/10/23.
//

import Foundation
import CoreData

class HeroMapViewModel: HeroMapControllerDelegate {
    
    //MARK: - Dependencies
    private let apiProvider: ApiProviderProtocol
    private let secureDataProvider: SecureDataProviderProtocol
    private let coreDataprovider = CoreDataProvider()
    
    var viewState: ((HeroMapViewState) -> Void)?
    
    //MARK: - Init
    init(apiProvider: ApiProviderProtocol, secureDataProvider: SecureDataProviderProtocol) {
        self.apiProvider = apiProvider
        self.secureDataProvider = secureDataProvider
    }
    
    //MARK: - Life Cycle
    func onViewDidLoad() {
        let locations = coreDataprovider.loadLocations()
        viewState?(.update(locations: locations))
    }
    
    //MARK: - Functions
    func heroById(_ id: String?) -> HeroDAO? {
        coreDataprovider.getHerowith(id: id)
    }
    
    func heroDetailViewModel(_ hero: HeroDAO ) -> HeroDetailViewControllerDelegate? {
        return HeroDetailViewModel(
            hero: hero,
            apiProvider: apiProvider,
            secureDataProvider: secureDataProvider)
    }
}
