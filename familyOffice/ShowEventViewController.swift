//
//  ShowEventViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 03/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MapKit
class ShowEventViewController: UIViewController, EventBindable {

    var event: Event!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    let locationManager = CLLocationManager()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    var remimberLabel: UILabel!
    var protocolNotification: NSObjectProtocol!
    @IBOutlet weak var startDatelabel: UILabel!
    @IBOutlet weak var imageTime: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.collectionView.register(UINib(nibName: "MemberInviteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "memberCell")
        let configurationButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Setting"), style: .plain, target: self, action:  #selector(self.handleConfiguration(_:)))
        
        self.navigationItem.rightBarButtonItems = [ configurationButton]
        // Do any additional setup after loading the view.
      
    }
    func handleConfiguration(_ sender: Any) {
        self.performSegue(withIdentifier: "confEventSegue", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.bind(event: event!)
        
        self.collectionView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.observeActions), name: notCenter.USER_NOTIFICATION, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func observeActions() -> Void {
         self.collectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if event?.location != nil {
            dropPinZoomIn()
        }
        
        self.collectionView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "confEventSegue" {
            let viewController = segue.destination as! ConfigurationEventTableViewController
            viewController.event = self.event!
        }
    }
    
    func dropPinZoomIn(){
        guard let latitude: CLLocationDegrees = event?.location?.latitude else{
            return
        }
        guard let longitude: CLLocationDegrees = event?.location?.longitude else{
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
 
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = event?.location?.title
        annotation.subtitle = event?.location?.subtitle
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }

}

extension ShowEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (event?.members.count)!
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! MemberInviteCollectionViewCell
        let member = (event?.members[indexPath.row])!
        let id : String = member.id
        if let user = store.state.UserState.user {
            cell.bind(userModel: user)
            cell.check.isHidden = false
            cell.check.image = member.statusImage()
            cell.check.layer.borderWidth = 2
            cell.check.layer.borderColor = UIColor.white.cgColor
        }else{
            store.dispatch(GetUserAction(uid: id))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
}
extension ShowEventViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}
