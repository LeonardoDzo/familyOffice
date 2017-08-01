//
//  GoalTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell, GoalBindable {
    var goal: Goal!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
