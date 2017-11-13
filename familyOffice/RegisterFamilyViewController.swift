//
//  RegisterFamilyViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import ReSwift
import ALCameraViewController

class RegisterFamilyViewController: UIViewController, FamilyBindable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, ContactsProtocol {
    var family: Family!
    var users: [User]! = []
    
    /// Variable para saber si cambio la foto o no para editar
    var change = false
    let picker = UIImagePickerController()
    typealias StoreSubscriberStateType = FamilyState
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var schearButton: UIButton!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var Image: CustomUIImageView!
    @IBOutlet weak var nameTxt: textFieldStyleController!
   
    @IBOutlet weak var viewcn: UIView!
    var blurImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loadImage(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        contentview.formatView()
        viewcn.formatView()
        Image.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func loadImage(_ recognizer: UITapGestureRecognizer){
        let croppingEnabled = true
        let _ = validate()
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (action: UIAlertAction) in
            let croppingEnabled = true
            let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: croppingEnabled, allowResizing: true, allowMoving: true)) { [weak self] image, asset in
                
                guard let img = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return
                }
                self?.Image.image = img
                self?.change = true
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
                self?.Image.image = img
                self?.change = true
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(imagePickerViewController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    @IBAction func handleClickContact(_ sender: UIButton) {
        self.pushToView(view: .contacts, sender: self)
    }

    
    func validate() -> Bool{
   
        
        if !users.contains((store.state.UserState.user)!){
            users.append((store.state.UserState.user)!)
        }
        
        guard let name = nameTxt.text, !name.isEmpty else {
            error()
            return false
        }
        self.family.name = name
        self.family.members = self.users.map({ $0.id})
        self.family.admin = (Auth.auth().currentUser?.uid)!
        
        return true
    }
    @objc func edit() -> Void {
        if validate() {
            if change {
                store.dispatch(UpdateFamilyAction(family: family, img: Image.image!))
                return
            }
            store.dispatch(UpdateFamilyAction(family: family))
        }else{
            error()
        }
    }
    @objc func save() -> Void {
        if !validate() {
            return
        }
        if Image.image != nil {
            store.dispatch(InsertFamilyAction(family: family, img: Image.image!))
        }else{
            error()
        }
    }
    func error() -> Void {
        service.UTILITY_SERVICE.enabledView()
        self.view.hideToastActivity()
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func selected(users: [User]) {
        self.users = users
        self.collectionView.reloadData()
    }
    
}
extension RegisterFamilyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMember", for: indexPath) as! memberSelectedCollectionViewCell
        let user = users[indexPath.row]
        cell.bind(userModel: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        users.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
}
extension RegisterFamilyViewController : StoreSubscriber {
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.FamilyState }
        }
        
        self.bind()
        
        family.members.forEach({uid in
            if let user = service.USER_SVC.getUser(byId: uid) {
                if !self.users.contains(user) {
                    self.users.append(user)
                }
            }
            
        })
        
        self.setupNavBar()
        self.collectionView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
        store.state.FamilyState.status = .none
    }
    
    func newState(state: FamilyState) {
        self.view.hideToastActivity()
        
        switch state.status {
        case .failed:
            error()
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            _ = self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    func setupNavBar() -> Void {
        if family.id.isEmpty {
            let saveButton = UIBarButtonItem(title: "Crear", style: .plain, target: self, action: #selector(self.save))
            navigationItem.rightBarButtonItems = [saveButton]
            navigationItem.title = "Crear Familia"
        }else{
            let update = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
            navigationItem.rightBarButtonItems = [update]
            navigationItem.title = "Actualizar Familia"
        }
        
    }
}
