//
//  mapViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class MapViewController : UIViewController {
    
    var selectedPin:MKPlacemark? = nil
    weak var shareEvent : ShareEvent?
    var resultSearchController:UISearchController? = nil
     var locationModel: Location!
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let storyboard: UIStoryboard = UIStoryboard(name: "Calendar", bundle: nil)
        let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        //SaveButton
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.addLocation))
        let quitButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.quitLocation))
        
        //Searchbutton
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Buscar lugares"
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.rightBarButtonItems = [addButton,quitButton]
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    func dismissPopover() {
        _ = navigationController?.popViewController(animated: true)    }
    
    @objc func addLocation() -> Void {
        
        if locationModel != nil {
            shareEvent?.event.location = locationModel
        }
        dismissPopover()

    }
    @objc func quitLocation() -> Void {
        if shareEvent?.event.location != nil {
            shareEvent?.event.location = nil
        }
          dismissPopover()
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        locationModel = Location(title: "", subtitle: "", latitude: 0, longitude: 0)
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            locationModel.title = placemark.name
            locationModel.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        locationModel.latitude = placemark.coordinate.latitude
        locationModel.longitude = placemark.coordinate.longitude
        
    }
}
