//
//  DesignableButton.swift
//  SkyApp
//
//  Created by Mark Moeykens on 12/18/16.
//  Copyright © 2016 Mark Moeykens. All rights reserved.
//

import UIKit

@IBDesignable
class UIButtonX: SpringButton {
    
    enum FromDirection:Int {
        case Top = 0
        case Right = 1
        case Bottom = 2
        case Left = 3
    }
    
    var shadowView: UIView!
    var direction: FromDirection = .Left
    var alphaBefore: CGFloat = 1
    
    
    @IBInspectable public var maskColor: UIColor = UIColor.clear {
        didSet {
            setImage( self.imageView?.image?.maskWithColor(color: maskColor), for: .normal)
        }
    }
    
    @IBInspectable public var filter: UIColor = UIColor.clear {
        didSet {
            let view = UIView(frame: frame)
            view.backgroundColor = filter
            addSubview(view)
        }
    }
    
    @IBInspectable var popIn: Bool = false
    @IBInspectable var popInDelay: Double = 0.4
    
    override func draw(_ rect: CGRect) {
        self.clipsToBounds = true
        
        if popIn {
            transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.8, delay: popInDelay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        
        if shadowView == nil && shadowOpacity > 0 {
            shadowView = UIView(frame: self.frame)
            shadowView.backgroundColor = UIColor.clear
            shadowView.layer.shadowColor = shadowColor.cgColor
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
            shadowView.layer.shadowOffset = shadowOffset
            shadowView.layer.shadowOpacity = Float(shadowOpacity)
            shadowView.layer.shadowRadius = shadowRadius
            shadowView.layer.masksToBounds = true
            shadowView.clipsToBounds = false
            
            self.superview?.addSubview(shadowView)
            self.superview?.bringSubview(toFront: self)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        alphaBefore = alpha
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            self.alpha = 0.4
        })
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .allowUserInteraction, animations: {
            self.alpha = self.alphaBefore
        })
    }
    
    // MARK: - Borders
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    // MARK: - Shadow
    
    @IBInspectable public var shadowOpacity: CGFloat = 0
    @IBInspectable public var shadowColor: UIColor = UIColor.clear
    @IBInspectable public var shadowRadius: CGFloat = 0
    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 0)
}
