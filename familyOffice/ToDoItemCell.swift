//
//  ToDoItemCell.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/3/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ToDoItemCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var checkFinished: UISwitch!
    @IBOutlet var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.countLabel.backgroundColor = #colorLiteral(red: 0.8426027298, green: 0.137216717, blue: 0.3985130191, alpha: 1)
        self.countLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.countLabel.layer.masksToBounds = true
        self.countLabel.layer.cornerRadius = 10
    }
    
    
}
