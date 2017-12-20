//
//  UILabel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension UILabel {
    
    func strikeText() -> Void {
        if !(self.text?.isEmpty)!{
            let attrString = NSMutableAttributedString(string: self.text!)
            attrString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue), range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
    func removeAttribute() -> Void {
        if !(self.text?.isEmpty)!{
            let attrString = NSMutableAttributedString(string: self.text!)
            attrString.removeAttribute(NSAttributedStringKey.strikethroughStyle, range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
    func setFormatter(_ formatter: DateFormatter, _ date: Int) -> Void {
        let xdate = Date(timeIntervalSince1970: TimeInterval(date/1000))
        self.text = xdate.string(with: formatter)
    }
   
    func editView() -> UIButton {
        let btn = UIButton(frame: CGRect(x: self.frame.origin.x +  self.bounds.size.width, y:  self.frame.origin.y + 5, width: 20, height: 20))
        btn.setImage(#imageLiteral(resourceName: "pencil-50").maskWithColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), for: .normal)
        return btn
    }
}
