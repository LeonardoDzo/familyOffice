//
//  FamilyCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamilyCollectionViewCell: UICollectionViewCell, FamilyBindable {
    var family: Family!
    @IBOutlet weak var Image: CustomUIImageView!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.Image.image = #imageLiteral(resourceName: "familyImage")
        self.Image.layer.cornerRadius = self.Image.frame.size.width/16
        self.Image.clipsToBounds = true
    }
    

}
