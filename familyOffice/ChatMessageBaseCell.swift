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
    let userColors = [UIColor.orange, UIColor.purple, UIColor.blue, UIColor.red, UIColor.magenta]

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var msgTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var leftConstraint: NSLayoutConstraint!
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    
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
    
    fileprivate func failedMessage() {
        bubbleView.backgroundColor = errColor
        userName.textColor = UIColor.white
        msgTextLabel.textColor = UIColor.white
        timeLabel.textColor = UIColor.white
    }
    
    func bind(message: MessageEntity, group: GroupEntity) {
        guard let user = rManager.realm.objects(UserEntity.self).filter("id == '\(message.remittent)'").first else {
            return
        }
        let mine = user.id == getUser()!.id
        let userIndex = group.members.index(matching: "id == '\(user.id)'") ?? 0
        msgTextLabel.text = message.text
        timeLabel.text = message.timestamp.string(with: DateFormatter.hourAndMin)
        userName.textColor = UIColor.black
        msgTextLabel.textColor = UIColor.black
        timeLabel.textColor = UIColor.black
        if !mine {
            userName.text = user.name
            userName.textAlignment = .left
            msgTextLabel.textAlignment = .left
            userName.textColor = userColors[userIndex % userColors.count]
            bubbleView.backgroundColor = otherColor
            rightConstraint.isActive = false
            leftConstraint.isActive = true
            if user.photoURL.isEmpty {
                userImg.image = #imageLiteral(resourceName: "user-default")
            } else {
                userImg.loadImage(urlString: user.photoURL)
            }
        } else {
            userName.text = ""
            userName.textAlignment = .right
            msgTextLabel.textAlignment = .right
            bubbleView.backgroundColor = mineColor
            leftConstraint.isActive = false
            rightConstraint.isActive = true
            userImg.image = nil
        }
        switch MessageStatus(rawValue: message.status) {
        case .Pending?:
            bubbleView.alpha = 0.5
        case .Sent?:
            bubbleView.alpha = 1
            break
        case .Failed?:
            failedMessage()
            break
        default: break
        }
    }
    
    func calcHeight(message: MessageEntity, width: CGFloat) -> CGFloat {
        let mine = message.remittent == getUser()!.id
        return message.text.height(withConstrainedWidth: width, font: msgTextLabel.font) + (mine ? 65 : 85)
    }

}
