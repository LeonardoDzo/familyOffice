//
//  FirstAidKitCell.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazar on 1/3/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit

class FirstAidKitCell: UITableViewCell {
    @IBOutlet weak var IndicatorView: UIViewX!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var container: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
