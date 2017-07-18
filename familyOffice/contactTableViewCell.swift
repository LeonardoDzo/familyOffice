//
//  contactTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class contactTableViewCell: UITableViewCell, ContactBindible {
    var contact: Contact!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var jobLbl: UILabel!
    @IBOutlet weak var callMember: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func callContact(_ sender: Any) {
        guard let number = URL(string: "tel://" + contact.phone!) else { return }
        UIApplication.shared.open(number)
    }
    
}
