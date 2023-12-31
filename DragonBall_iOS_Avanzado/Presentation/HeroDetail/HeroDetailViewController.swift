//
//  HeroDetailViewController.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 20/10/23.
//

import UIKit
import MapKit
import Kingfisher

//MARK: - Protocol
protocol HeroDetailViewControllerDelegate {
    var viewState: ((HeroDetailViewState) -> Void)? { get set }
    func onViewAppear ()
    func addObserverErrors()
    func removeObserverErrors()
}
//MARK: - View State
enum HeroDetailViewState {
    case loading(_ isloading: Bool)
    case update(hero: HeroDAO?, locations: [LocationDAO]?)
    case apiError(_ error: String)
}

//MARK: - Class
class HeroDetailViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var heroeDescription: UITextView!
    @IBAction func backToLastScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - IBAction
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    var viewModel: HeroDetailViewControllerDelegate?
    
    //MARK: - Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        viewModel?.onViewAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.onViewAppear()
    }
    
    //MARK: - Private Functions
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading(let isLoading):
                    self?.activityIndicator.isHidden = !isLoading
                    
                case .update(let hero, let locations):
                    self?.updateViews(hero: hero, heroLocations: locations)
                case .apiError(let error):
                    debugPrint(error)
                }
            }
        }
    }
    
    private func updateViews(hero: HeroDAO?, heroLocations: [LocationDAO]?) {
        photo.kf.setImage(with: URL(string: hero?.photo ?? ""))
        makeRounded(image: photo)
        name.text = hero?.name
        heroeDescription.text = hero?.heroDescription
        
        heroLocations?.forEach {
            mapView.addAnnotation(
                HeroAnnotation(
                    title: hero?.name,
                    info: hero?.id,
                    coordinate: .init(latitude: Double($0.latitude ?? "") ?? 0.0,
                                      longitude: Double($0.longitude ?? "") ?? 0.0)
                )
            )
        }
        
        if let coordinate = mapView.annotations.first?.coordinate {
            mapView.centerCoordinate = coordinate
        }
    }
    
    private func makeRounded(image: UIImageView) {
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.orange.cgColor.copy(alpha: 0.5)
        image.layer.cornerRadius = image.frame.height / 2
        image.layer.masksToBounds = false
        image.clipsToBounds = true
    }
}
