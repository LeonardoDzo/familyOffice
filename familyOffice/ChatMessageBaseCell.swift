//
//  ChatMessageBaseCell.swift
//  familyOffice
//
//  Created by Nan Montaño on 13/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChatMessageBaseCell: UITableViewCell {

    let mineColor = UIColor(hex: "#e3e3e3")
    let otherColor = UIColor.white

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 2
        self.backgroundColor = UIColor.clear
        userImg.layer.cornerRadius = 22.5
        userImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(message: MessageEntity, user: UserEntity, mine: Bool) {
        msgTextLabel.text = message.text
        if !mine {
            userName.text = user.name
            userName.textAlignment = .left
            msgTextLabel.textAlignment = .left
            bubbleView.backgroundColor = otherColor
            userImg.loadImage(urlString: user.photoURL)
        } else {
            userName.text = "Yo"
            userName.textAlignment = .right
            msgTextLabel.textAlignment = .right
            bubbleView.backgroundColor = mineColor
            userImg.image = nil
        }
    }
    
    func calcHeight(text: String, width: CGFloat) -> CGFloat {
        return text.height(withConstrainedWidth: width, font: msgTextLabel.font) + 70
    }

}
