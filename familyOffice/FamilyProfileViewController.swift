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
    var family: FamilyEntitie!
    @IBOutlet weak var Image: CustomUIImageView!
    @IBOutlet weak var membersTable: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.state.FamilyState.status = .none
        self.Image.editBtn()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editImage))
        self.Image.addGestureRecognizer(tapGesture)
        
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
extension FamilyProfileViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return family != nil ? family.members.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyMemberTableViewCell
        let human = family.members[indexPath.row].value
        if let member = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: human) {
            cell.bind(userModel: member)
        }

        return cell
    }
  
}
extension FamilyProfileViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    override func viewWillAppear(_ animated: Bool) {

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
            family = rManager.realm.object(ofType: FamilyEntitie.self, forPrimaryKey: family.id)
            self.bind()
            break
        default:
            break
        }
        
        switch state.UserState.user {
            case .finished:
                self.membersTable.reloadData()
            default:
                self.membersTable.reloadData()
            break
        }
    }
    
    
    
}
