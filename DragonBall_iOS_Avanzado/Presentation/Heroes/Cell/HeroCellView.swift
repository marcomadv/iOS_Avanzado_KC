//
//  HeroCellView.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 17/10/23.
//

import UIKit

class HeroCellView: UITableViewCell {
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
    }
    
    func updateView() {
        
    }
}
