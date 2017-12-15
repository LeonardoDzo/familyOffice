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
        
        collectionView.register(UINib(nibName: "FamilyMember1Cell", bundle: nil), forCellWithReuseIdentifier: "CellMember")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleAddNewMember(_ sender: UIButton) {
        self.pushToView(view: .contacts, sender: self.family)
    }
    
    @objc func editImage() -> Void {
        let alertController = UIAlertController(title: "Qué desea hacer?", message: nil, preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Cambiar foto", style: .default, handler: { (action) -> Void in
            let cropping = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 80, height: 80))
          

            /// Provides an image picker wrapped inside a UINavigationController instance
            let imagePickerViewController = CameraViewController.imagePickerViewController(croppingParameters:cropping) { [weak self] image, asset in
                if image != nil {
                    store.dispatch(FamilyS(FamilyAction.uploadImage(img: image!, family: (self?.family)!)))
                }
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(imagePickerViewController, animated: true, completion: nil)
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
        store.subscribe(self) {
            $0.select({ (s) in
                s
            })
        }
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
