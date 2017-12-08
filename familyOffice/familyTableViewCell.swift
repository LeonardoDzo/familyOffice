//
//  familyTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class familyTableViewCell: UITableViewCell, FamilyEBindable {
    var family: FamilyEntity!
    @IBOutlet weak var photo : UIImageViewX!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var memberscount: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
