//
//  EventDetailsViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MapKit
import ReSwift
class EventDetailsViewController: UIViewController, EventEBindable {
    var event: EventEntity!
    var members = [memberEventEntity]()
    @IBOutlet weak var backgroundType: UIImageViewX!
    @IBOutlet weak var detailsTxtV: UITextView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet var statusBtns: [UIButtonX]!
    
    @IBOutlet weak var statusView: UIViewX!
    @IBOutlet weak var locationstack: UIStackView!
    @IBOutlet weak var membersStack: UIStackView!
    @IBOutlet weak var detailsStack: UIStackView!
    
    fileprivate func reloadMembers() {
        members.removeAll()
        if event.members.count > 0 {
            members.append(contentsOf:  event.members)
        }else if event.father != nil {
            members.append(contentsOf:  (event.father?.members)!)
        }
        if event.members.count < (event.father?.members.count)! {
           
           // members.append()
        }
        self.members.forEach { (member) in
            if let _ = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: member.id) {
            }else{
                store.dispatch(UserS(.getbyId(uid: member.id)))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtonback()
        statusView.animate()
        reloadMembers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleAction(_ sender: UIButtonX) {
        try! rManager.realm.write {
            var member = event.members.first(where: {$0.id == getUser()?.id})
            if member == nil{
                let newmember = memberEventEntity(uid: (getUser()?.id)!)
                member = newmember
            }
            
            if let me = member, let status = sender.restorationIdentifier {
                switch status {
                case "confirmed":
                    me.status = .confirmed
                    break
                case "tentative":
                    me.status = .tentative
                    break
                case "canceled":
                    me.status = .canceled
                    break
                default:
                    me.status = .none
                    break
                }
               
                
                if let index = event.members.index(where: {$0.id == me.id})  {
                    event.members[index] = me
                }else{
                    event.members.append(me)
                }
                self.bind()
                saveforthis()
            }
        }
        
    }
    func saveforthis() -> Void {
        let alertController = UIAlertController(title: "Aplicar cambios para?", message: "", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Solo Este", style: .default, handler: { (action) -> Void in
            self.safeForAll(false)
        })
        let deleteButton = UIAlertAction(title: "Para todos los siguientes", style: .default, handler: { (action) -> Void in
            self.safeForAll(true)
        })
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func safeForAll(_ flag: Bool) -> Void {
        try! rManager.realm.write {
            self.event.changesforAll = flag
            if event.father != nil {
                if let index = self.event.father?.following.index(where: {$0.id == self.event.id}) {
                    event.father?.following[index] = self.event
                }else{
                    event.father?.following.append(self.event)
                }
            }
        }
        event.updateEvents(following: self.event)
        self.collectionView.reloadData()
    }
}
extension EventDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return  members.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! memberEntityCollectionCell
        if let mid = self.members[indexPath.row].id {
            if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: mid) {
                cell.bind(sender: user)
                cell.profileImage.layer.borderWidth = 2
                cell.profileImage.layer.borderColor = self.members[indexPath.row].status.color.cgColor
            }
        }
        return cell
    }
}
extension EventDetailsViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = EventState
    override func viewWillAppear(_ animated: Bool) {
        self.bind()
        if event.location == nil, event.father?.location == nil {
            locationstack.isHidden = true
        }
        print(self.event)
        store.subscribe(self) {
            $0.select({ (s)  in
                s.EventState
            })
        }
    }
    func newState(state: EventState) {
        self.collectionView.reloadData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        
    }
}
