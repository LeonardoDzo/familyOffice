//
//  ChatDetailsFormController.swift
//  familyOffice
//
//  Created by Nan Montaño on 16/ene/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Eureka

class ChatDetailsFormController: FormViewController, GroupBindible {
    var group: GroupEntity!
    let user = getUser()!
    var otherUser: UserEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.form.removeAll()
            self.setup()
        }
    }
    
    func setup() {
        if !group.isGroup, let otherId = group.members.first(where: { $0.id != user.id })?.id {
            otherUser = rManager.realm.objects(UserEntity.self).first(where: { $0.id == otherId })
        }
        
        let isFamilyGroup = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: group.id) != nil
        if group.isGroup && !isFamilyGroup {
            let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
            self.navigationItem.rightBarButtonItem = button
        }
        
        form +++ Section() { section in
                var header = HeaderFooterView<UIImageView>(.class)
                header.height = {self.view.frame.width}
                header.onSetupView = { view, _ in
                    if let otherUser = self.otherUser {
                        if let url = otherUser.photoURL.notEmpty() {
                            view.loadImage(urlString: url)
                        } else {
                            view.image = #imageLiteral(resourceName: "user-default")
                        }
                    } else {
                        if let url = self.group.coverPhoto.notEmpty() {
                            view.loadImage(urlString: url)
                        } else {
                            view.image = #imageLiteral(resourceName: "background_family")
                        }
                    }
                }
                section.header = header
            }
            <<< LabelRow() { row in
                row.title = otherUser?.name ?? group.title
            }.onCellSelection { (cell, row) in
                if let otherUser = self.otherUser {
                    self.pushToView(view: .profileView, sender: otherUser)
                }
            }
        if group.isGroup {
            var rows: [BaseRow] = group.members.filter({ $0.id != self.user.id }).map({ member in
                return LabelRow() { row in
                    guard let user = rManager.realm.objects(UserEntity.self).first(where: { $0.id == member.id }) else {
                        return
                    }
                    if let url = user.photoURL.notEmpty() {
                        row.cell.imageView?.loadImage(urlString: url)
                    } else {
                        row.cell.imageView?.image = #imageLiteral(resourceName: "user-default")
                    }
                    row.title = user.name
                    row.onCellSelection({ (cell, row) in
                        self.pushToView(view: .profileView, sender: user)
                    })
                }
            })
            rows.insert(LabelRow() { row in
                if let url = user.photoURL.notEmpty() {
                    row.cell.imageView?.loadImage(urlString: url)
                } else {
                    row.cell.imageView?.image = #imageLiteral(resourceName: "user-default")
                }
                row.title = "Yo"
                row.onCellSelection({ (cell, row) in
                    self.pushToView(view: .profileView, sender: self.user)
                })
            }, at: 0)
            var section = Section("\(group.members.count) Miembros")
            section += rows
            form +++ section
            
        }
    }
    
    @objc func edit() {
        let ctrl = NewChatGroupForm()
        ctrl.group = self.group
        show(ctrl, sender: self)
    }
    
}
