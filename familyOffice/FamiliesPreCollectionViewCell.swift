//
//  FamiliesPreCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamiliesPreCollectionViewCell: UICollectionViewCell, FamilyBindable {
    var family: Family!
    @IBOutlet weak var Image: CustomUIImageView!
    @IBOutlet weak var check: UIImageView!
    @IBOutlet weak var Title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.check.layer.cornerRadius = 15
        self.check.layer.borderWidth = 3
        self.check.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        self.Image.image = #imageLiteral(resourceName: "familyImage")
        self.Image.layer.cornerRadius = 5
        self.Image.clipsToBounds = true
        self.Image.layer.borderWidth = 1
        self.Image.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.Image.layer.cornerRadius = 5
        self.Title.textColor = #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1)
    }
}
