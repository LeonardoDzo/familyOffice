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
    let errColor = UIColor.red

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
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
        timeLabel.text = message.timestamp.string(with: DateFormatter.hourAndMin)
        userName.textColor = UIColor.black
        msgTextLabel.textColor = UIColor.black
        timeLabel.textColor = UIColor.black
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
        switch MessageStatus(rawValue: message.status) {
        case .Pending?:
            bubbleView.alpha = 0.5
        case .Sent?:
            bubbleView.alpha = 1
            break
        case .Failed?:
            bubbleView.backgroundColor = errColor
            userName.textColor = UIColor.white
            msgTextLabel.textColor = UIColor.white
            timeLabel.textColor = UIColor.white
            break
        default: break
        }
    }
    
    func calcHeight(text: String, width: CGFloat) -> CGFloat {
        return text.height(withConstrainedWidth: width, font: msgTextLabel.font) + 85
    }

}
