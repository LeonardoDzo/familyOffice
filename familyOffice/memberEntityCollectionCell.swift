//
//  memberEntityCollectionCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class memberEntityCollectionCell: UICollectionViewCell, UserEModelBindable {
    var userModel: UserEntity!
   
    @IBOutlet weak var profileImage: UIImageViewX!
    
    override func awakeFromNib() {
        profileImage.animate()
    }
}
