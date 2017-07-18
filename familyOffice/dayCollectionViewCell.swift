//
//  dayCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class dayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLbl: UILabel!
    override func awakeFromNib() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.width/2
    }
}
