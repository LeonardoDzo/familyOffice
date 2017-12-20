//
//  MemberTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class MemberTableViewCell:  UITableViewCell, UserEModelBindable {
  
    var userModel: UserEntity!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageViewX!
    @IBOutlet weak var phoneLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


