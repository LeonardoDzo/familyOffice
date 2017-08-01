//
//  TimeLineCellTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class TimeLineCellTableViewCell: UITableViewCell {
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var doneLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        doneLbl.layer.borderColor = UIColor.black.cgColor
        doneLbl.layer.borderWidth = 1
        doneLbl.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
