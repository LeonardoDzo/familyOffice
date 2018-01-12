//
//  homesCollectionViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift

class homesCollectionViewCell: UICollectionViewCell {
    var btn : homesBtn!
        @IBOutlet weak var icon: UIImageViewX!
    @IBOutlet weak var badge: UILabelX!
    
    func updateUI(_ value: Int = 0) {
        self.badge.isHidden = value > 0 ? false : true
        self.badge.text = String(value)
    }
    
   
    override func awakeFromNib() {
        icon.delay = CGFloat(0.2)
        icon.animate()
        
    }
    func verifyNotifications(_ results: Results<NotificationModel>) {
        let value = results.filter("type = %@ AND seen = %@", btn.type.rawValue, false).count
        updateUI(value)
    }
    
}
