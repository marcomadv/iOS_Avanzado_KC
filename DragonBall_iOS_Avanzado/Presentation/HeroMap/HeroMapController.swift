//
//  HeroMap.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 21/10/23.
//

import UIKit
import MapKit

//MARK: - View State
enum HeroMapViewState {
    case update(locations: [LocationDAO])
}

//MARK: - Protocol
protocol HeroMapControllerDelegate {
    var viewState: ((HeroMapViewState) -> Void)? { get set }
    func onViewDidLoad()
    func heroById(_ id: String?) -> HeroDAO?
    func heroDetailViewModel(_ hero: HeroDAO ) -> HeroDetailViewControllerDelegate?
}

//MARK: - Class
class HeroMapController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var heroMap: MKMapView!
    
    var viewModel: HeroMapControllerDelegate?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setOservers()
        viewModel?.onViewDidLoad()
    }
    
    //MARK: - Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MAP_TO_DETAIL" {
            guard let hero = sender as? HeroDAO,
                  let heroDetailViewController = segue.destination as? HeroDetailViewController,
                  let heroDetailViewModel = viewModel?.heroDetailViewModel(hero) else { return }
            heroDetailViewController.viewModel = heroDetailViewModel
        }
    }
    
    func initViews() {
        heroMap.delegate = self
    }
    
    func setOservers() {
        viewModel?.viewState = { [weak self] state in
            switch state {
            case .update(locations: let locations):
                self?.updateViews(locations: locations)
            }
        }
    }
    
    func updateViews(locations: [LocationDAO]) {
        for loc in locations {
            let annotation = HeroAnnotation(
                title: loc.hero?.name,
                info: loc.hero?.id,
                coordinate: .init(latitude: Double(loc.latitude ?? "") ?? 0.0,
                                  longitude: Double(loc.longitude ?? "") ?? 0.0))
            heroMap.addAnnotation(annotation)
        }
    }
}

//MARK: - Extension
extension HeroMapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard let idHero = ( annotation as? HeroAnnotation)?.info as? String?,
              let hero = viewModel?.heroById(idHero) else { return }
        performSegue(withIdentifier: "MAP_TO_DETAIL", sender: hero)
    }
}
