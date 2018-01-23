//
//  MainTabBarController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 26/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        if let str: String = self.restorationIdentifier {
            switch str {
            case "tabbarfirstAidKit":
                self.setStyle(.firstaidkit)
                break
            case "tabbarchat":
                self.setStyle(.chat)
                break
            case "TabBarControllerView":
                self.tabBar.items?.last?.title = "Perfil"
                self.tabBar.items?.last?.image = #imageLiteral(resourceName: "Setting")
                break
            case "tabbarAssistant":
                self.setStyle(.assistant)
                let chatViewController = ChatTextViewController()
                var group : GroupEntity!
                if let uid = getUser()?.assistants.first?.key {
                    group = rManager.realm.objects(GroupEntity.self).first { group in
                        if !group.isGroup {
                            var flag = false
                            flag = group.members.contains(where: {$0.id == getUser()?.id}) && group.members.contains(where: {$0.id == uid})
                            return flag
                        }
                        return false
                    }
                    if group == nil {
                        group = GroupEntity()
                        
                        let myId = getUser()?.id
                        group?.id = "\(uid < myId! ? uid : myId!)-\(uid < myId! ? myId! : uid)"
                        group?.members.append(TimestampEntity(value: [uid, Date()]))
                        group?.members.append(TimestampEntity(value: [myId!, Date()]))
                        group?.isGroup = false
                        store.dispatch(createGroupAction(group: group, uuid: group.id))
                    }else{
                        chatViewController.group = group
                    }
                }
                chatViewController.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "chat-room"), tag: 2)
                self.viewControllers?.append(chatViewController)
                break
            default:
                break
            }

        }
        self.setupBack()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
    }

}
