//
//  FamilyTitleView.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FamilyTitleView: UIView, FamilyEBindable {
    var family: FamilyEntity!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var titleLbl: UILabel!
    
    class func instanceFromNib() -> FamilyTitleView {
        return UINib(nibName: "FamilyTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FamilyTitleView
    }
}
