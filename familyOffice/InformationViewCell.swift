//
//  InformationViewCell.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/21/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class InformationViewCell: UITableViewCell {

    @IBOutlet var informationLabel: UILabel!
    
    @IBOutlet var iLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
