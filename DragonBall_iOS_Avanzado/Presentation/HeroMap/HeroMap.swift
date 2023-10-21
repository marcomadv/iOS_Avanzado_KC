//
//  HeroMap.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 21/10/23.
//

import UIKit
import MapKit

class HeroMap: UIViewController {
    
    @IBAction func backToHeroes(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var heroMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
