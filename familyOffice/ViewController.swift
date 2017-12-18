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

enum StyleNavBar  {
    case calendar,
         firstaidkit,
         chat
}
extension StyleNavBar {
    func style() -> (UIColor, UIColor)? {
        switch self {
        case .calendar:
            return (#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .firstaidkit:
            return (#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .chat:
            return (#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        }
    }
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
    
    func setStyle(_ style: StyleNavBar) -> Void {
        if let value = style.style() {
              self.navigationController?.navigationBar.barTintColor = value.0
              self.navigationController?.navigationBar.tintColor = value.1
        }
    }
    
    func setupButtonback() -> Void {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        let backBtn = UIButton(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        backBtn.setImage( #imageLiteral(resourceName: "back-27x20").maskWithColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), for: .normal)
        backBtn.addTarget(self, action: #selector(self.back3), for: UIControlEvents.allEvents)
        self.view.addSubview(backBtn)
    }
    
    func setupBack() -> Void {
        var backBtn :UIBarButtonItem!
        backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back-27x20").maskWithColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)), style: .plain, target: self, action: #selector(self.back3))
        
        self.navigationItem.leftBarButtonItem = backBtn
    }
    @objc func back3() -> Void {
        if (navigationController?.popViewController(animated: true)) != nil {
           
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.navigationController?.setToolbarHidden(false, animated: true)
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
    
    func gotoView(view: RoutingDestination, sender: Any? = nil, navigation: Bool? = false)  {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        var viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        if let vc = viewcontroller as? bind {
            vc.bind(sender: sender)
        }
        if let flag = navigation, flag {
            viewcontroller = UINavigationController(rootViewController: viewcontroller)
            
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
        case let vc as ChatGroupViewController:
            if sender is  GroupEntity {
                vc.group = sender as! GroupEntity
            }
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
