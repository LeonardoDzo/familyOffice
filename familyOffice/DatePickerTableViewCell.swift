//
//  DatePickerTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 31/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datepicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
