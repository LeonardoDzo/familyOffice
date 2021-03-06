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
import ALCameraViewController
protocol bind {
    func bind(sender: Any?) -> Void
}

enum StyleNavBar  {
    case calendar,
         firstaidkit,
         chat,
         insurance,
         safebox,
         assistant
}
extension StyleNavBar {
    func style() -> (UIColor, UIColor)? {
        switch self {
        case .calendar:
            return (#colorLiteral(red: 1, green: 0.2901960784, blue: 0.3529411765, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .firstaidkit:
            return (#colorLiteral(red: 0.5490196078, green: 0.5294117647, blue: 0.7843137255, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .chat:
            return (#colorLiteral(red: 0.01568627451, green: 0.7019607843, blue: 0.9960784314, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .insurance:
            return (#colorLiteral(red: 0.1137254902, green: 0.7176470588, blue: 0.4352941176, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .safebox:
            return (#colorLiteral(red: 0.9607843137, green: 0.7215686275, blue: 0.1176470588, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        case .assistant:
            return (#colorLiteral(red: 0.9529411765, green: 0.5137254902, blue: 0.3529411765, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.navigationController?.setToolbarHidden(false, animated: true)
    }
    @objc func back() -> Void {
        
        self.dismiss(animated: true, completion: nil)
    }
    func top() -> UIViewController {
        return UIApplication.topViewController() ?? self
    }
    @objc func selectImage( completion: @escaping (UIImage?) -> Void) {
        let croppingEnabled = true
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (action: UIAlertAction) in
            let croppingEnabled = true
            let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: croppingEnabled, allowResizing: true, allowMoving: true)) { [weak self] image, asset in
                
                guard image != nil else {
                    self?.dismiss(animated: true, completion: nil)
                    completion(nil)
                    return
                }
                completion(image)
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(cameraViewController, animated: true, completion: nil)
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Galería", style: .default, handler: { (action: UIAlertAction) in
            
            /// Provides an image picker wrapped inside a UINavigationController instance
            let imagePickerViewController = CameraViewController.imagePickerViewController(croppingParameters: CroppingParameters(isEnabled: croppingEnabled, allowResizing: true, allowMoving: true)) { [weak self] image, asset in
                guard image != nil else {
                    completion(nil)
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
               completion(image)
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(imagePickerViewController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
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
    func getController(_ view: RoutingDestination, _ sender: Any? = nil) -> UIViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: view.getStoryBoard(), bundle: nil)
        let viewcontroller : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: view.rawValue)
        
        
        if  let vc = viewcontroller as? bind {
            vc.bind(sender: sender)
        }
        
        switch viewcontroller {
        case let vc as FamilyViewController:
            var family : Family
            if sender == nil {
                return nil
            }else{
                family = sender as! Family
            }
            vc.bind(fam: family)
            break
        case let vc as ChatTextViewController:
            if sender is  GroupEntity {
                vc.group = sender as! GroupEntity
            }
            break
        default:
            break
        }
        
        return viewcontroller
    }
    
    func pushToView(view: RoutingDestination, sender: Any? = nil) -> Void {
        if let viewcontroller = getController(view, sender) {
            if let nav = self.navigationController {
                nav.pushViewController(viewcontroller, animated: true)
            }else{
                let targetViewController = viewcontroller // this is that controller, that you want to be embedded in navigation controller
                let targetNavigationController = UINavigationController(rootViewController: targetViewController)
                
                self.present(targetNavigationController, animated: true, completion: nil)
            }
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
