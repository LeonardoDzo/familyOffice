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
        let view = UIView(frame: CGRect(x:self.frame.width - 30, y: self.frame.height - 30, width: 30, height: 30))
        view.backgroundColor = #colorLiteral(red: 0.3621918559, green: 0.3622578681, blue: 0.3621831834, alpha: 0.5574567195)
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        
        let btnEdit = UIImageView()
        btnEdit.frame.size = CGSize(width: 30, height: 30)
        btnEdit.frame.origin = view.bounds.origin
        btnEdit.frame.origin.x += 2
        btnEdit.frame.origin.y += 2
        btnEdit.image = #imageLiteral(resourceName: "edit_image")
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

