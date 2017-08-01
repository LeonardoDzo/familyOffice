//
//  UIString.swift
//  familyOffice
//
//  Created by miguel reina on 15/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

extension String
{
    func encodeUrl() -> String
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    func decodeUrl() -> String
    {
        return self.removingPercentEncoding!
    }
    
}
