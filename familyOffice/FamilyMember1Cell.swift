//
//  FamilyMember_1CollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamilyMember1Cell: UICollectionViewCell, UserEModelBindable {

    
    var userModel: UserEntity!
    
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var isAdmin: UILabelX!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
