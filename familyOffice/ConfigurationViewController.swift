//
//  ConfigurationViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 27/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import FirebaseAuth
import ALCameraViewController
import ReSwift
class ConfigurationViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {
    var user: User!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    let picker = UIImagePickerController()
    var chosenImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        picker.delegate = self
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        self.containerView.formatView()
        self.profileImage.profileUser()
    }
    override func viewWillAppear(_ animated: Bool) {
        user = store.state.UserState.user!
        profileImage.loadImage(urlString: user.photoURL)
        store.subscribe(self) {
            $0.select({
                s in
                s.UserState
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated:true, completion: { _ in
            self.performSegue(withIdentifier: "updateImageSegue", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImage(_ sender: UIButton) {
        let croppingEnabled = true
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (action: UIAlertAction) in
            let croppingEnabled = true
            let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: croppingEnabled, allowResizing: true, allowMoving: true)) { [weak self] image, asset in
                
                guard let img = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                store.dispatch(UpdateUserAction(user: (self?.user)!, img: img))
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(cameraViewController, animated: true, completion: nil)
            
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Galería", style: .default, handler: { (action: UIAlertAction) in
            
            /// Provides an image picker wrapped inside a UINavigationController instance
            let imagePickerViewController = CameraViewController.imagePickerViewController(croppingParameters: CroppingParameters(isEnabled: croppingEnabled, allowResizing: true, allowMoving: true)) { [weak self] image, asset in
                guard let img = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                store.dispatch(UpdateUserAction(user: (self?.user)!, img: img))
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(imagePickerViewController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)

        
    }
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        self.present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
}

extension ConfigurationViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    
    func newState(state: UserState) {
        user = store.state.UserState.user!
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            profileImage.loadImage(urlString: user.photoURL)
            break
        case .failed:
            self.view.makeToast("Algo salio mal", duration: 3.0, position: .center)
            break
        default:
            break
        }
    }
}
