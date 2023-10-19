//
//  HeroCellView.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 17/10/23.
//

import UIKit
import Kingfisher

class HeroCellView: UITableViewCell {
    static let identifier: String = "HeroCellView"
    static let estimatedHeight: CGFloat = 256
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var heroeDescription: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        name.text = nil
        photo.image = nil
        heroeDescription.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //propiedades de la tarjeta
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.5
        
        selectionStyle = .none
    }
    
    func updateView(name: String? = nil,
                    photo: String? = nil,
                    description:String? = nil
    ) {
        self.name.text = name
        self.heroeDescription.text = description
        self.photo.kf.setImage(with: URL(string: photo ?? ""))
    }
}
