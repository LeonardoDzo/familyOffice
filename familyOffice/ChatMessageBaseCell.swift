//
//  ChatMessageBaseCell.swift
//  familyOffice
//
//  Created by Nan Montaño on 13/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChatMessageBaseCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 2
        bubbleView.backgroundColor = UIColor.lightGray
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(message: MessageEntity, user: UserEntity, mine: Bool) {
        msgTextLabel.text = message.text
        userName.text = user.name
        userImg.loadImage(urlString: user.photoURL)
    }
    
    func calcHeight(text: String, width: CGFloat) -> CGFloat {
        return text.height(withConstrainedWidth: width, font: msgTextLabel.font) + 70
    }

}
