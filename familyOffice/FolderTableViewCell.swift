//
//  FolderTableViewCell.swift
//  familyOffice
//
//  Created by Developer on 8/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var folderNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
