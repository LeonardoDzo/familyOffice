//
//  FirstAidTableViewCell.swift
//  familyOffice
//
//  Created by Nan Montaño on 11/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FirstAidTableViewCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        frame = CGRect(
            origin: frame.origin,
            size: CGSize(width: frame.width, height: 68)
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            frame = CGRect(
                origin: frame.origin,
                size: CGSize(width: frame.width, height: 148)
            )
        } else {
            frame = CGRect(
                origin: frame.origin,
                size: CGSize(width: frame.width, height: 68)
            )
        }
        // Configure the view for the selected state
    }

}
