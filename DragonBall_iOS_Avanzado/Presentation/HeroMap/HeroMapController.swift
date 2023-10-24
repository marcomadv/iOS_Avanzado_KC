//
//  HeroMap.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 21/10/23.
//

import UIKit
import MapKit

protocol HeroMapControllerDelegate {
    func onViewDidLoad()
}

class HeroMapController: UIViewController {
    @IBOutlet weak var heroMap: MKMapView!
    
    var viewModel: HeroMapControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.onViewDidLoad()
    }
    
    
}
