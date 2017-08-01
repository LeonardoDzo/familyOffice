//
//  PersonalDataTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PersonalDataTableViewCell: UITableViewCell {

    @IBOutlet weak var myTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        myTextField.tintColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        myTextField.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String?, placeholder: String ) -> Void {
        myTextField.text = text
        myTextField.placeholder = placeholder
    }
   
}
