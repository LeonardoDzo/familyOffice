//
//  homesCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class homesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageViewX!
    override func awakeFromNib() {
        icon.delay = CGFloat(0.2)
        icon.animate()
    }
}
