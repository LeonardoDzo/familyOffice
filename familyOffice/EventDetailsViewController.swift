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
    let locationManager = CLLocationManager()
    var myLocation : CLLocationCoordinate2D!
    var previewActions: [UIPreviewAction] = []
    var members = [memberEventEntity]()
    var ctrl: UIViewController!
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
    @IBOutlet weak var editBtn: UIButtonX!
    
    fileprivate func reloadMembers() {
        members.removeAll()
        if event.members.count > 0 {
            members.append(contentsOf:  event.members)
        }
        
        if event.father != nil {
            event.father?.members.forEach({ (member) in
                if !members.contains(where: {$0.id == member.id}) {
                     members.append(member)
                }
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let accept = UIPreviewAction(title: "Aceptar", style: .selected, handler: { (UIPreviewAction, UIViewController) in
            self.handleAction(self.statusBtns[2])
        })
        let pending = UIPreviewAction(title: "Pendiente", style: .selected, handler: { (UIPreviewAction, UIViewController) in
            self.handleAction(self.statusBtns[1])
        })
        let reject = UIPreviewAction(title: "Rechazar", style: .selected, handler: { (UIPreviewAction, UIViewController) in
            self.handleAction(self.statusBtns[0])
        })
        let delete = UIPreviewAction(title: "Eliminar", style: .destructive, handler: { (UIPreviewAction, UIViewController) in
            self.deleteEvent()
        })
        self.previewActions.append(contentsOf: [accept,pending,reject])
        if self.event.admins.contains(where: {$0.value == getUser()?.id}) || (self.event.father?.admins.contains(where: {$0.value == getUser()?.id}))! {
            self.previewActions.append(delete)
        }
        statusView.animate()
        reloadMembers()
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.directionTapped))
        addressLbl.isUserInteractionEnabled = true
        addressLbl.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        self.mapView = nil
    }
    @IBAction func handleEdit(_ sender: UIButton) {
        self.pushToView(view: .addEvent, sender: self.event)
    }
    
    fileprivate func deleteEvent() {
         let father = self.event.getFather()
        //0 hace referencia a que jamás se repetira este evento
        let freq = father.repeatmodel?.frequency.rawValue ?? 0
        if  0 == freq {
            store.dispatch(EventSvc(.delete(eid: father)))
        }else{
            deleteJustThis()
        }
        
       
    }
    
    func deleteJustThis() -> Void {
        let father = self.event.getFather()
        let alertController = UIAlertController(title: " Cuales desea eliminar?", message: "", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Solo Este", style: .destructive, handler: { (action) -> Void in
            if self.event.isChild {
                try! rManager.realm.write {
                    self.event.isDeleted = true
                }
                rManager.save(objs: self.event)
               store.dispatch(EventSvc(.update(event: father)))

            }else{
                if let event = rManager.realm.objects(EventEntity.self).filter("father = %@", father).sorted(byKeyPath: "startdate").first {

                    try! rManager.realm.write {
                        self.event.startdate = event.startdate
                        self.event.enddate = event.enddate
                    }
                    rManager.save(objs: father)
                    store.dispatch(EventSvc(.update(event: father)))
                }
        }
        })
        
        let deleteButton = UIAlertAction(title: "Todos los siguientes", style: .destructive, handler: { (action) -> Void in
            
            if self.event.isChild {
                try! rManager.realm.write {
                    father.repeatmodel?.end = self.event.enddate
                }
                store.dispatch(EventSvc(.update(event: father)))
            }else{
                
                store.dispatch(EventSvc(.delete(eid: father)))
            }
        })
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        let xctrl = ctrl ?? self
        xctrl.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func handleAction(_ sender: UIButtonX) {
      try! rManager.realm.write {
            var member = event.members.first(where: {$0.id == getUser()?.id})
            if event.father != nil {
                if member != nil{
                    rManager.realm.delete(member!)
                }
                
            }
            let newmember = memberEventEntity(uid: (getUser()?.id)!)
            member = newmember
            
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
                
            }
        }
        if let father = self.event.father != nil ? self.event.father  : self.event {
            //0 hace referencia a que jamás se repetira este evento
            let freq = father.repeatmodel?.frequency.rawValue ?? 0
            if  0 == freq {
                store.dispatch(EventSvc(.update(event: father)))
            }else{
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
        let xctrl = ctrl ?? self
        xctrl.present(alertController, animated: true, completion: nil)
        
       
    }
    
    func safeForAll(_ flag: Bool) -> Void {
        let father = self.event.getFather()
        try! rManager.realm.write {
            self.event.changesforAll = flag
        }
            if flag {
                let events = rManager.realm.objects(EventEntity.self).filter("father = %@ AND startdate > %@",father, self.event.startdate)
                
                    events.forEach({ (event) in
                        event.members.enumerated().forEach({ (i, member) in
                            if self.event.members.contains(where: {$0.id == member.id}) {
                                 try! rManager.realm.write {
                                    event.members.remove(at: i)
                                }
                            }
                        })
                        event.update(self.event)
                    })
                  
                
            }
          try! rManager.realm.write {
            if self.event.isChild {
                if let index = father.following.index(where: {$0.id == self.event.id}) {
                    father.following[index] = self.event
                }else{
                    father.following.append(self.event)
                }
            }
        }
       
        
        store.dispatch(EventSvc(.update(event: father)))
    }

}
extension EventDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mid = self.members[indexPath.row].id, let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: mid) {
                 self.pushToView(view: .profileView, sender: user)
        
        }
        
    }
    
    
}
extension EventDetailsViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = EventState
    fileprivate func pin(_ location: Location?) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location!.title
        annotation.subtitle = location?.subtitle ?? ""
        annotation.forwardingTarget(for: #selector(self.directionTapped))
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.bind()
        self.setupButtonback()
        
        
        let details = event.details.isEmpty ? event.father?.details : event.details
        if  (details?.isEmpty)! {
            detailsStack.isHidden = true
        }
        let father = self.event.getFather()
        self.editBtn.isHidden = father.admins.contains(where :{ $0.value == getUser()?.id}) ? false : true
        store.subscribe(self) {
            $0.select({ (s)  in
                s.EventState
            })
        }
    }
    
    @objc func directionTapped() {
        let openMapsActionSheet = UIAlertController(title: "Open in Maps", message: "Choose a maps application", preferredStyle: .actionSheet)
        openMapsActionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { (action: UIAlertAction!) -> Void in
            let placemark = MKPlacemark(coordinate: (self.mapView.annotations.first?.coordinate)!, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            let options = [MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving,
                           MKLaunchOptionsShowsTrafficKey: true] as [String : Any]
           item.openInMaps(launchOptions: options)
        }))
        
        let latitud = String(self.mapView.annotations.first!.coordinate.latitude)
        let longitude = String(self.mapView.annotations.first!.coordinate.longitude)
        
        openMapsActionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (action: UIAlertAction!) -> Void in
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?saddr=\(self.myLocation.latitude),\(self.myLocation.longitude)&daddr=\(latitud),\(longitude)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "http://maps.google.com/maps?saddr=\(self.myLocation.latitude),\(self.myLocation.longitude)&daddr=\(latitud),\(longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
            }
        }))
        openMapsActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(openMapsActionSheet, animated: true, completion: nil)
    }
    func newState(state: EventState) {
        reloadMembers()
        self.bind()
        let location = event.location == nil ? event.father?.location : event.location
        if location == nil {
            locationstack.isHidden = true
        }else{
            pin(location)
        }
        self.collectionView.reloadData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        
    }
    
}
extension EventDetailsViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = manager.location?.coordinate
    }
}
