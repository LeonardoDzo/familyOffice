//
//  PreviewEvent.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PreviewEvent: UIView {

    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PreviewEvent", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
   

}


