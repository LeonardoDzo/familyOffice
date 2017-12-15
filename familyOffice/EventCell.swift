//
//  EventCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell, EventEBindable {
    var event: EventEntity!
    
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
