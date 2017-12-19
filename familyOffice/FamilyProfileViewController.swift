//
//  FamilyProfileViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift
import ReSwift
import PhotosUI
import ALCameraViewController

class FamilyProfileViewController: UIViewController, FamilyEBindable {
    var notificationToken: NotificationToken? = nil
    var family: FamilyEntity!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = UITapGestureRecognizer(target: self, action: #selector(self.editImage))
        photo.editBtn()
        photo.isUserInteractionEnabled = true
        photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.editImage)))
        collectionView.register(UINib(nibName: "FamilyMember1Cell", bundle: nil), forCellWithReuseIdentifier: "CellMember")
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleAddNewMember(_ sender: UIButton) {
        self.gotoView(view: .contacts, sender: self.family, navigation: true)
    }
    
    @objc func editImage() -> Void {
        let alertController = UIAlertController(title: "Qué desea hacer?", message: nil, preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Cambiar foto", style: .default, handler: { (action) -> Void in
            self.selectImage(completion: { (image) in
                if image != nil {
                    store.dispatch(FamilyS(FamilyAction.uploadImage(img: image!, family: (self.family)!)))
                }
            })
        })
        let seeButton = UIAlertAction(title: "Ver foto", style: .default, handler: { (action) -> Void in
            if self.Image != nil, self.Image.image != nil {
                self.showImages(images: [self.Image.image!])
            }
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(seeButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
extension FamilyProfileViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return family.members.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellMember", for: indexPath) as! FamilyMember1Cell
        let uid = family.members[indexPath.row].value
        cell.bind(id: uid)
        if family.admins.contains(where: {$0.value == uid}) {
            cell.isAdmin.isHidden = false
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uid = family.members[indexPath.row].value
        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: uid) {
            self.pushToView(view: .profileView, sender: user)
        }
    }
}
extension FamilyProfileViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    override func viewWillAppear(_ animated: Bool) {
        store.state.FamilyState.status = .none
        self.setupButtonback()
        self.bind()
        titleLbl.sizeToFit()
        
        store.subscribe(self) {
            $0.select({ (s) in
                s
            })
        }
    }
    fileprivate func addEditBtn() {
        if let v = self.view.viewWithTag(100) {
            v.removeFromSuperview()
        }
        let btnEdit = titleLbl.editView()
        btnEdit.tag = 100
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.edittitle))
        btnEdit.addGestureRecognizer(tap)
        btnEdit.isUserInteractionEnabled = true
        titleLbl.isUserInteractionEnabled = true
        titleLbl.addGestureRecognizer(tap)
        self.view.addSubview(btnEdit)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addEditBtn()
    }
    
   @objc func edittitle() -> Void {
        let alertController = UIAlertController(title: "Editar nombre de familia:", message: "Ingresa el nombre de la familia", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Actualizar", style: .default) { (_) in
            
            guard let text = alertController.textFields?[0].text, !text.isEmpty else {
                return
            }
            try! rManager.realm.write {
                self.family.name = text
            }
            store.dispatch(FamilyS(.update(family: self.family)))
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Nombre de la familia"
            textField.text = self.family.name
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func newState(state: AppState) {
        self.view.isUserInteractionEnabled = true
        switch state.FamilyState.status {
        case .loading:
            self.view.isUserInteractionEnabled = false
            break
        case .Finished(_ as FamilyAction):
            family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: family.id)
            self.bind()
            addEditBtn()
            break
        default:
            break
        }
        
        switch state.UserState.user {
            case .finished, .Finished(_):
                self.collectionView.reloadData()
            default:
            break
        }
    }
    
    
    
}
