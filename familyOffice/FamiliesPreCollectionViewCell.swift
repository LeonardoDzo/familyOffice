//
//  FamiliesPreCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamiliesPreCollectionViewCell: UICollectionViewCell, FamilyEBindable {
    var family: FamilyEntity!
    @IBOutlet weak var check: UIImageViewX!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.check.layer.cornerRadius = 15
        self.check.layer.borderWidth = 3
        self.check.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
    }
}
