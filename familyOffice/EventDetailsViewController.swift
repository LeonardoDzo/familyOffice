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
    
    @IBOutlet weak var backgroundType: UIImageView!
    @IBOutlet weak var detailsTxtV: UITextView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.setupButtonback()
        self.event.members.forEach { (member) in
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
        return event.members.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! memberEntityCollectionCell
        if let mid = event.members[indexPath.row].id {
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
