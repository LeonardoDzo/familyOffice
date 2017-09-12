//
//  DesignableTextField.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 31/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class DesignableTextField: UITextField {
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    func updateView(){
        if let img = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: 20, height: 20))
            imageView.image = img
            let width = leftPadding + 20
            let view = UIView(frame:  CGRect(x:0, y: 0, width: width, height: 20))
            view.addSubview(imageView)
            
            leftView = view
        }else{
            leftViewMode = .never
        }
    }
}
