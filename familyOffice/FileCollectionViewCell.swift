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
    @IBOutlet weak var fileExtLabel: UILabel!
    
    override func awakeFromNib() {
    }
}
