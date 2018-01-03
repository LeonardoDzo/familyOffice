//
//  NotificationCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 20/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell, NotificationBindible {
    
    

    var notification: NotificationModel!
    @IBOutlet weak var bodyTxtV: UITextView!
    @IBOutlet weak var typeImg: UIImageViewX!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
