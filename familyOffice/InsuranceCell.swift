//
//  InsuranceCell.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class InsuranceCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var policyLbl: UILabel!
    @IBOutlet weak var telephoneLbl: UILabel!
    @IBOutlet weak var attachment: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
