//
//  GalleryState.swift
//  familyOffice
//
//  Created by Enrique Moya on 06/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct GalleryState: StateType {
    var Gallery: [String:[Album]] = [:]
    var Album: Album
    var status: Result<Any> 
}
