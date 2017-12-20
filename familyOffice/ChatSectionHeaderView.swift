//
//  ChatSectionHeaderView.swift
//  familyOffice
//
//  Created by Nan Montaño on 20/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

func ChatSectionHeaderView(tableFrame: CGRect, text: String) -> UIView {
    
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.size.width, height: 25))
    let font = UIFont.systemFont(ofSize: 12)
    let width = text.width(withConstraintedHeight: font.lineHeight, font: font) + 10
    let padding = (tableFrame.size.width - width)/2
    let label = UILabel(frame: CGRect(x: padding, y: 5, width: width, height: font.lineHeight + 5))
    label.layer.cornerRadius = 5
    label.backgroundColor = UIColor.lightGray
    label.font = font
    label.text = text
    label.textAlignment = .center
    view.addSubview(label)
    return view
}
