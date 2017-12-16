//
//  NewChatGroupForm.swift
//  familyOffice
//
//  Created by Nan Montaño on 15/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Eureka
import ImageRow
import RealmSwift
import ReSwift
import FirebaseStorage

class NewChatGroupForm : FormViewController {
    
    var group = GroupEntity()
    var editUuid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(
            title: "Crear",
            style: .done,
            target: self,
            action: #selector(self.done)
        )
//        button.isEnabled = false
        self.navigationItem.rightBarButtonItem = button
        
        form +++ Section()
            <<< TextRow() {
                $0.title = "Nombre"
                $0.add(rule: RuleRequired())
                $0.tag = "title"
                $0.validationOptions = .validatesOnChange
            } <<< ImageRow() {
                $0.title = "Foto de grupo"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: .destructive)
                $0.tag = "photo"
            }
            <<< UsersRow() {
                $0.title = "Miembros"
                $0.tag = "members"
            }
    }
    
    @objc func done(_ sender: Any) {
        let values = form.values()
        group.title = values["title"] as! String
        group.id = UUID().uuidString
        group.familyId = getUser()!.familyActive
        group.createdAt = Date()
        let membersArray = values["members"] as! UserListSelected
        membersArray.list.forEach({ userId in
            group.members.append(RealmString(value: [userId]))
        })
        store.dispatch(createGroupAction(group: group, uuid: group.id))
    }
    
    func uploadImage() {
        guard let img = form.values()["photo"] as? UIImage else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        service.STORAGE_SERVICE.insertImageSmall("/groups/\(group.id)", value: img, callback: { metadata in
            guard let meta = metadata as? StorageMetadata else {
                return
            }
            let url = meta.downloadURL()?.absoluteString ?? ""
            self.editUuid = UUID().uuidString
            store.dispatch(addPhotoGroupAction(group: self.group, photoUrl: url, uuid: self.editUuid!))
        })
    }
    
}

extension NewChatGroupForm: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.subscribe(self) { store in
            store.select({ $0.requestState })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        if !group.id.isEmpty {
            switch state.requests[group.id] {
            case .finished?:
                uploadImage()
                break
            default: return
            }
        }
        if let uuid = editUuid {
            switch state.requests[uuid] {
            case .finished?:
                navigationController?.popViewController(animated: true)
                break
            default: return
            }
        }
        
    }
}
