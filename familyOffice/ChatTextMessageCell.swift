//
//  ChatTextMessageCell.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/ene/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import Stevia

class ChatTextMessageCell: UITableViewCell {
    
    let mineColor = UIColor(hex: "#e3e3e3")
    let otherColor = #colorLiteral(red: 0.9523342252, green: 0.9724559188, blue: 0.9851050973, alpha: 1)
    let errColor = UIColor.red
    let userColors = [UIColor.orange, UIColor.purple, UIColor.blue, UIColor.red, UIColor.magenta]

    var userImg = UIImageView()
    var bubbleView = UIView()
    var userName = UILabel()
    var msgText = UILabel()
    var msgTime = UILabel()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
    }
    
    func render() {
        
        // addSubViews
        sv(
            bubbleView.sv(
                userName.text("Someone"),
                msgText,
                msgTime.text("Sometime")
            ),
            userImg.image("user-default")
        )
        
        // layout
        userImg.top(5).left(5).width(40).height(40)
        bubbleView.bottom(7.5).top(7.5).layout(
            5,
            |-25-userName-5-| ~ (<=25),
            |-25-msgText-10-| ~ (>=14),
            5,
            |-10-msgTime-10-| ~ 12,
            5
        )
        
        // style
        userImg.style { i in
            i.layer.cornerRadius = 20
            i.clipsToBounds = true
        }
        bubbleView.style { v in
            v.layer.cornerRadius = 5
            v.clipsToBounds = true
        }
        msgText.style { l in
            l.font = UIFont.systemFont(ofSize: 14)
            l.lineBreakMode = .byWordWrapping
            l.numberOfLines = 10
        }
        msgTime.style { l in
            l.font = UIFont.systemFont(ofSize: 10)
            l.textAlignment = .right
            l.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }

    func bind(message: MessageEntity) {
        guard let group = rManager.realm.objects(GroupEntity.self).first(where: { $0.id == message.groupId}) else {
            return
        }
        guard let user = rManager.realm.objects(UserEntity.self).first(where: { $0.id == message.remittent }) else {
            bindWithAssistant(message: message)
            return
        }
        let mine = user.id == getUser()!.id
        let userIndex = group.members.index(matching: "id == '\(user.id)'") ?? 0
        msgText.text = message.text
        msgTime.text = message.timestamp.string(with: DateFormatter.hourAndMin)
        if !mine {
            userName.text = user.name
            msgText.textAlignment = .left
            userName.textColor = userColors[userIndex % userColors.count]
            bubbleView.backgroundColor = otherColor
            bubbleView.right(>=15).left(25)
            if user.photoURL.isEmpty {
                userImg.image = #imageLiteral(resourceName: "user-default")
            } else {
                userImg.loadImage(urlString: user.photoURL)
            }
        } else {
            userName.text = ""
            msgText.textAlignment = .right
            bubbleView.backgroundColor = mineColor
            bubbleView.left(>=15).right(15)
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
        layoutIfNeeded()
    }
    func bindWithAssistant(message: MessageEntity) -> Void {
        guard let group = rManager.realm.objects(GroupEntity.self).first(where: { $0.id == message.groupId}) else {
            return
        }
        guard let user = rManager.realm.objects(AssistantEntity.self).first(where: { $0.id == message.remittent }) else {
            return
        }
        let mine = user.id == getUser()!.id
        let userIndex = group.members.index(matching: "id == '\(user.id)'") ?? 0
        msgText.text = message.text
        msgTime.text = message.timestamp.string(with: DateFormatter.hourAndMin)
        if !mine {
            userName.text = user.name
            msgText.textAlignment = .left
            userName.textColor = userColors[userIndex % userColors.count]
            bubbleView.backgroundColor = otherColor
            bubbleView.right(>=15).left(25)
            if user.photoURL.isEmpty {
                userImg.image = #imageLiteral(resourceName: "user-default")
            } else {
                userImg.loadImage(urlString: user.photoURL)
            }
        } else {
            userName.text = ""
            msgText.textAlignment = .right
            bubbleView.backgroundColor = mineColor
            bubbleView.left(>=15).right(15)
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
        layoutIfNeeded()
    }
    
    fileprivate func failedMessage() {
        bubbleView.backgroundColor = errColor
        userName.textColor = UIColor.white
        msgText.textColor = UIColor.white
        msgTime.textColor = UIColor.white
    }
}
