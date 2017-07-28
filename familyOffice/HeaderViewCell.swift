//
//  HeaderViewCell.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/21/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class HeaderViewCell: UITableViewCell {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var hLabel: UILabel!
    @IBOutlet var arrowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
