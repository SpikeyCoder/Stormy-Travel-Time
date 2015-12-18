//
//  MapsRemoteDataController.swift
//  Stormy Travel Time
//
//  Created by Armstrong, Kevin M. on 8/14/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import GoogleMaps

class MapsRemoteDataController: NSObject
{
    let baseURLGeocode = "https:?/maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
 
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void))
    {
           var counting = self.fetchedFormattedAddress.characters.count
        if let lookupAddress = address {
            var geocodeURLString = self.baseURLGeocode
        }
    }
    
}