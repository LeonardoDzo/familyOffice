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
            attrString.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue), range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
    func removeAttribute() -> Void {
        if !(self.text?.isEmpty)!{
            let attrString = NSMutableAttributedString(string: self.text!)
            attrString.removeAttribute(NSStrikethroughStyleAttributeName, range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
    func setFormatter(_ formatter: DateFormatter, _ date: Int) -> Void {
        let xdate = Date(timeIntervalSince1970: TimeInterval(date/1000))
        self.text = xdate.string(with: formatter)
    }
    
}
