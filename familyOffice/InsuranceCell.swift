//
//  InsuranceCell.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class InsuranceCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var policyLbl: UILabel!
//    @IBOutlet weak var telephoneLbl: UILabel!
    @IBOutlet weak var attachment: UIImageView!
    @IBOutlet weak var phoneTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        phoneTextView.isEditable = false
        phoneTextView.dataDetectorTypes = UIDataDetectorTypes.all
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension InsuranceCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.openURL(URL)
            return true
        }
        return false
    }
}
