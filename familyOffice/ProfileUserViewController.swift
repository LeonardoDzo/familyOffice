//
//  ProfileUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class ProfileUserViewController: UIViewController, UserEModelBindable{
 
    var userModel: UserEntity! = getUser()
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var confBtn: UIButton!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var infoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
       self.bind()
        if !userModel.isUserLogged() {
            confBtn.isHidden = true
            logoutBtn.isHidden = true
        }else{
            callBtn.isHidden = true
            msgBtn.isHidden = true
        }
        
        store.subscribe(self) {
            state in
            state.select({ (s) in
                s.authState
            })
        }
        
        if  tabBarController?.restorationIdentifier != "TabBarControllerView" || (tabBarController?.tabBar.isHidden)! {
            self.setupButtonback()
        }
       
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        store.dispatch(AuthSvc(.logout))
    }
    @IBAction func msgBtnPressed(_ sender: Any) {
        var controller = ChatGroupViewController()
        let user = getUser()
        let uid = userModel.id
        let myId = (user?.id)!
        var group : GroupEntity! = nil
        
        group = rManager.realm.objects(GroupEntity.self).first { group in
            if !group.isGroup {
                var flag = false
                flag = group.members.contains(where: {$0.id == myId}) && group.members.contains(where: {$0.id == uid})
                return flag
            }
            return false
        }
        if group == nil {
            group = GroupEntity()
            
            group?.id = "\(uid < myId ? uid : myId)-\(uid < myId ? myId : uid)"
            group?.members.append(TimestampEntity(value: [uid, Date()]))
            group?.members.append(TimestampEntity(value: [myId, Date()]))
            group?.familyId = (user?.familyActive)!
            group?.isGroup = false
//            store.dispatch(createGroupAction(group: group, uuid: group.id))
        }else{
            self.pushToView(view: .chat, sender: group)
        }
    }
    
    @IBAction func callBtnPressed(_ sender: Any) {
        if let url = URL(string: "tel://\(userModel.phone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    @IBAction func handleGoConfig(_ sender: Any) {
        self.gotoView(view: .confView, sender: self.userModel, navigation: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "infoSegue" {
            if let vc = segue.destination as? InfoUserViewController {
                vc.bind(userModel: self.userModel)
            }
        }
    }
}

extension ProfileUserViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = AuthState
    
    func newState(state: AuthState) {
        switch state.state {
        case .Finished(let action as AuthAction):
            self.dismiss(animated: true, completion: nil)
            break
        default: break
        }
        
    }
}


