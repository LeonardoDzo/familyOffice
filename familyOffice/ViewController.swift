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
protocol bind {
    func bind(sender: Any?) -> Void
}

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
    func setupBack() -> Void {
        var backBtn :UIBarButtonItem!
        if let _ = self.navigationController {
            backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Home").maskWithColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), style: .plain, target: self, action: #selector(self.back3))
        } else {
            backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Home").maskWithColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), style: .plain, target: self, action: #selector(self.back3))
        }
        
        self.navigationItem.leftBarButtonItem = backBtn
    }
    @objc func back3() -> Void {
        if (navigationController?.popViewController(animated: true)) != nil {
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func back() -> Void {
        
        self.dismiss(animated: true, completion: nil)
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
    
    func gotoView(view: RoutingDestination, sender: Any? = nil )  {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        if let vc = viewcontroller as? bind {
            vc.bind(sender: sender)
        }
        if let tb = viewcontroller as? UITabBarController {
            tb.setupBack()
            if let nv = tb.viewControllers?.first as? UINavigationController {
                if let vc = nv.viewControllers.first as? bind {
                    vc.bind(sender: sender)
                }
            }
        }
        
        self.present(viewcontroller, animated: true, completion: nil)
    }
    
    
    func pushToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        
        if  let vc = viewcontroller as? bind {
            vc.bind(sender: sender)
        }
        
        switch viewcontroller {
        case let vc as FamilyViewController:
            var family : Family
            if sender == nil {
                return
            }else{
                family = sender as! Family
            }
            vc.bind(fam: family)
        break
        default:
            break
        }
        
        if let nav = self.navigationController {
            nav.pushViewController(viewcontroller, animated: true)
        }else{
            let targetViewController = viewcontroller // this is that controller, that you want to be embedded in navigation controller
            let targetNavigationController = UINavigationController(rootViewController: targetViewController)
            
            self.present(targetNavigationController, animated: true, completion: nil)
        }
    }
    func popToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        if let nav = self.navigationController {
              nav.popToViewController(viewcontroller, animated: true)
        }else{
            let targetViewController = viewcontroller // this is that controller, that you want to be embedded in navigation controller
            let targetNavigationController = UINavigationController(rootViewController: targetViewController)
            
            self.present(targetNavigationController, animated: true, completion: nil)
        }
        
      
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
