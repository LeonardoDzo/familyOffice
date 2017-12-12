//
//  Location.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import MapKit
import Firebase
import RealmSwift

@objcMembers
public class Location : Object, Codable, Serializable
{

    dynamic open var title : String = ""
    dynamic open var subtitle : String = ""
    dynamic open var latitude : Double = 0.0
    dynamic open var longitude: Double = 0.0
    
    convenience public init(_ placeMark: MKPlacemark) {
        self.init()
        self.title = placeMark.title ?? ""
        self.latitude = placeMark.coordinate.latitude
        self.longitude = placeMark.coordinate.longitude
    }
}
