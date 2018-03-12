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
    
    let user = getUser()!
    var group = GroupEntity()
    var createUuid: String?
    var editUuid: String?
    var deleteUuid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(
            title: "Listo",
            style: .done,
            target: self,
            action: #selector(self.done)
        )
        button.isEnabled = !group.id.isEmpty
        self.navigationItem.rightBarButtonItem = button
        
        let section = Section()
        form +++ section
            <<< PushRow<FamilyEntity>() {
                $0.disabled = Condition.function([], { _ in !self.group.id.isEmpty })
                $0.title = "Familia"
                $0.selectorTitle = "Selecciona una familia"
                $0.tag = "family"
                $0.options = rManager.realm.objects(FamilyEntity.self).map({ $0 })
                $0.value = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: group.familyId)
                $0.validationOptions = .validatesOnChange
            }.onChange({ pushRow in
                let usersRow = self.form.rowBy(tag: "members") as! UsersRow
                usersRow.familyId = pushRow.value?.id
                usersRow.value = UserListSelected()
                button.isEnabled = self.form.validate(includeHidden: true).count == 0
            }) <<< TextRow() {
                $0.title = "Nombre"
                $0.add(rule: RuleRequired())
                $0.tag = "title"
                $0.validationOptions = .validatesOnChange
                $0.value = group.title
            }.onChange({ nameRow in
                let errs = self.form.validate(includeHidden: true)
                button.isEnabled = errs.count == 0
            }) <<< ImageRow() {
                $0.title = "Foto de grupo"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.clearAction = .yes(style: .destructive)
                $0.tag = "photo"
                if let cacheImage = imageCache.object(forKey: group.coverPhoto as AnyObject) {
                    $0.value = cacheImage as? UIImage
                }
            } <<< UsersRow() {
                $0.hidden = Condition.function(["family"], { form in
                    return (form.rowBy(tag: "family") as? PushRow<FamilyEntity>)?.value == nil
                })
                $0.familyId = group.familyId
                $0.title = "Miembros"
                $0.tag = "members"
                $0.value = UserListSelected(list: group.members.map({ $0.id }))
                $0.validationOptions = .validatesOnChange
                var rules = RuleSet<UserListSelected>()
                rules.add(rule: RuleClosure<UserListSelected> { rowValue in
                    return rowValue!.list.count < 2 ? ValidationError(msg: "2 o mas miembros requeridos") : nil
                })
                $0.add(ruleSet: rules)
                }.onChange({ nameRow in
                    button.isEnabled = self.form.validate(includeHidden: true).count == 0
                })
        if !group.id.isEmpty {
            section <<< ButtonRow() {
                $0.title = "Eliminar grupo"
            }.cellUpdate({ cell, row in
                cell.textLabel?.textColor = UIColor.red
            }).onCellSelection({ cell, row in
                let ctrl = UIAlertController(title: "¿Seguro que quiere eliminar el grupo?", message: nil, preferredStyle: .alert)
                ctrl.addAction(UIAlertAction(title: "Aceptar", style: .destructive, handler: { (_) in
                    self.deleteUuid = UUID().uuidString
                    store.dispatch(deleteGroupAction(group: self.group, uuid: self.deleteUuid!))
                }))
                ctrl.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
                self.present(ctrl, animated: true, completion: nil)
            })
        }
    }
    
    @objc func done(_ sender: Any) {
        let values = form.values()
        let _group = GroupEntity()
        _group.title = values["title"] as! String
        _group.id = UUID().uuidString
        let fam = values["family"] as! FamilyEntity
        _group.familyId = fam.id
        _group.createdAt = Date()
        let membersArray = values["members"] as! UserListSelected
        membersArray.list.forEach({ userId in
            let oldMember = group.members.first(where: { $0.id == userId })
            _group.members.append(oldMember ?? TimestampEntity(value: [userId, Date()]))
        })
        createUuid = UUID().uuidString
        if group.id.isEmpty {
            store.dispatch(createGroupAction(group: _group, uuid: createUuid!))
        } else {
            // solo actualiza nombre, miembros y foto
            store.dispatch(editGroupAction(group: group, fields: _group, uuid: createUuid!))
        }
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
        if let uuid = createUuid {
            switch state.requests[uuid] {
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
        if let uuid = deleteUuid {
            switch state.requests[uuid] {
            case .finished?:
                let ctrlArr = self.navigationController!.viewControllers
                let ctrl = ctrlArr[ctrlArr.count - 4]
                self.navigationController?.popToViewController(ctrl, animated: true)
            default: return
            }

        }
        
    }
}
