//
//  ChatGroupCell.swift
//  familyOffice
//
//  Created by Nan Montaño on 15/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChatGroupCell: UITableViewCell {
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var lastMsg: UILabel!
    @IBOutlet weak var msgTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(group: GroupEntity, lastMessage: MessageEntity? = nil) {
        if !group.coverPhoto.isEmpty {
            groupImg.loadImage(urlString: group.coverPhoto)
        } else {
            groupImg.image = #imageLiteral(resourceName: "background_family")
        }
        groupName.text = group.title
        if let msg = lastMessage {
            lastMsg.text = msg.text
            msgTime.text = msg.timestamp.string(with: DateFormatter.hourAndMin)
        }
    }

}
