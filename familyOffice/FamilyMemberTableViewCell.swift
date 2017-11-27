//
//  FamilyMemberTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamilyMemberTableViewCell: UITableViewCell, UserEModelBindable {
    var userModel: UserEntitie!
    var filter: String!
    @IBOutlet weak var adminlabel: UILabel!
    @IBOutlet weak var profileImage: UIImageViewX!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.image = #imageLiteral(resourceName: "profile_default")
    
        self.profileImage.formatView()
        self.profileImage.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
