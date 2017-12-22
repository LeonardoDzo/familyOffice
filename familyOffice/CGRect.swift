//
//  CGRect.swift
//  familyOffice
//
//  Created by Nan Montaño on 21/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension CGRect {
    func withSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CGRect {
        return CGRect(
            x: self.origin.x,
            y: self.origin.y,
            width: width ?? self.size.width,
            height: height ?? self.size.height)
    }
}
