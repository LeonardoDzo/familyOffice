//
//  PendingCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
class PendingCell: UITableViewCellX, PendingBindable {
    var pending: PendingEntity!
    var content : contentPending!
    var priority = UIViewX()
    
    
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder)}
   
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func render() {
        content = contentPending(pending: pending)
        
        sv(
            content,
            priority
        )
        layout(
            10,
            |-priority.width(5).height(100%)-0-content.height(87)-|,
            2
        )
        
        priority.backgroundColor = pending.priority.color
        self.animation = "slideUp"
        self.animate()
        
    }

}

class contentPending: UIViewX, PendingBindable {
    var pending: PendingEntity!
    
    var titleLbl: UILabelX!  = UILabelX()
    var detailsTxtV: UITextView! = UITextView()
    var doneImg: UIImageViewX! = UIImageViewX()
    var updatedAtLbl: UILabelX! = UILabelX()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(pending: PendingEntity) {
        
        self.init(frame: .zero)
        self.pending = pending
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func render() -> Void {
        doneImg = UIImageViewX()
        self.bind(sender: pending)
        
        
        sv(
           doneImg,
           titleLbl,
           detailsTxtV,
           updatedAtLbl
        )
        layout(
            8,
            |-titleLbl-doneImg.width(20).height(20)-| ~ 13,
            0,
            |-detailsTxtV.height(60%)-2-|,
            0,
            updatedAtLbl-|,
            3
        )
        self.borderWidth = 1
        self.borderColor = pending.seen ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : UIColor.clear
        updatedAtLbl.font = updatedAtLbl.font.withSize(12)
        updatedAtLbl.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        detailsTxtV.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        detailsTxtV.backgroundColor = UIColor.clear
        self.backgroundColor = pending.seen ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.9529411765, green: 0.5137254902, blue: 0.3529411765, alpha: 0.03898914319)
    }

}
