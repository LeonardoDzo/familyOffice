//
//  memberSelectedCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class memberSelectedCollectionViewCell: UICollectionViewCell, UserEModelBindable {
    var userModel: UserEntity!
    
    var filter: String!
    @IBOutlet weak var profileImage: UIImageViewX!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.image = #imageLiteral(resourceName: "profile_default")
        self.profileImage.circleImage()
    }
   
}
