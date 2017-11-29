//
//  UIView.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    func addContraintWithFormat(format: String, views: UIView...)  {
        var viewsDictionary = [String:UIView]()
        for (index,view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    func withPadding(padding: UIEdgeInsets) -> UIView {
        let container = UIView()
        container.addSubview(self)
        snp.makeConstraints( { make in
            make.edges.equalTo(container).inset(padding)
        })
        return container
    }
    
    func formatView() -> Void {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
    }
    
    func editBtn() {
        let view = UIView(frame: CGRect(x:self.frame.width - 20, y: self.frame.height - 20, width: 20, height: 20))
        view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 0.7917380137)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
      
        let btnEdit = UIImageView()
        btnEdit.frame.size = CGSize(width: 15, height: 15)
        btnEdit.frame.origin = view.bounds.origin
        btnEdit.frame.origin.x += 2
        btnEdit.frame.origin.y += 2
        btnEdit.image = #imageLiteral(resourceName: "edit").maskWithColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        view.addSubview(btnEdit)
        self.addSubview(view)
    }
}
extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}

