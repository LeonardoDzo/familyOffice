//
//  ViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Lightbox
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self as? UIGestureRecognizerDelegate
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func alertMessage(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func style_1() -> Void {
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        nav?.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
    }
    
    func gotoView(view: RoutingDestination )  {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let homeViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    
    func pushToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        
        switch viewcontroller {
        case let vc as FamilyProfileViewController:
            var family = FamilyEntitie()
            if sender != nil {
                family = sender as! FamilyEntitie
            }
            vc.bind(fam: family)
        case let vc as FamilyViewController:
            var family : Family
            if sender == nil {
                return
            }else{
                family = sender as! Family
            }
            vc.bind(fam: family)
        break
        case let vc as ContactsViewController:
            vc.contactDelegate = sender as! ContactsProtocol
            break
        case let vc as addEventTableViewController:
            vc.event = sender as! Event
            break
        default:
            break
        }
        
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func openNotification(data: Any? = nil) -> Void {
     
    }
    
    func showImages(images: [UIImage]) -> Void {
        
        if  images.count == 0 {
            return
        }
        
        var imgs  = [LightboxImage]()
        
        imgs = images.map({ (img) -> LightboxImage in
            return LightboxImage(image: img)
        })
        
        let controller = LightboxController(images: imgs)
        controller.dynamicBackground = true
        self.present(controller, animated: true, completion: nil)
    }

}
