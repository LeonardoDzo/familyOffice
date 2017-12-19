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
    
    @IBOutlet weak var locationstack: UIStackView!
    @IBOutlet weak var membersStack: UIStackView!
    @IBOutlet weak var detailsStack: UIStackView!
    
    override func viewDidLoad() {
       super.viewDidLoad()
       self.setupButtonback()
        members.removeAll()
        if event.members.count > 0 {
            members.append(contentsOf:  event.members)
        }else if event.father != nil {
            members.append(contentsOf:  (event.father?.members)!)
        }
        
        self.members.forEach { (member) in
            if let _ = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: member.id) {
            }else{
                store.dispatch(UserS(.getbyId(uid: member.id)))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
