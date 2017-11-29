//
//  pendingQuestionCell.swift
//  familyOffice
//
//  Created by Developer on 8/15/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class pendingQuestionCell: UITableViewCell {

    @IBOutlet weak var pendingQLabel: UILabel!
    @IBOutlet weak var numberPQ: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.numberPQ.backgroundColor = #colorLiteral(red: 0.8426027298, green: 0.137216717, blue: 0.3985130191, alpha: 1)
        self.numberPQ.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.numberPQ.layer.masksToBounds = true
        self.numberPQ.layer.cornerRadius = 10

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
