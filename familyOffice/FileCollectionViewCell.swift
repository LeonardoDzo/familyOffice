//
//  FileCollectionViewCell.swift
//  familyOffice
//
//  Created by Developer on 8/15/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var FileIconImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    override func awakeFromNib() {
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
    }
}
