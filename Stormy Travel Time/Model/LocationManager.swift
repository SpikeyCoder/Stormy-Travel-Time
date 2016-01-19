//
//  LocationManager.swift
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 1/19/16.
//  Copyright © 2016 Armstrong Enterprises. All rights reserved.
//

import UIKit

enum LocationUpdateStrings
{
    case LocationChanged
    case LocationUpdateKey
    case LocationUpdatesDenied
    
    func name() -> String
    {
        switch self
        {
            case .LocationChanged:
                return "com.armstrongapp.LocationChanged"
            case .LocationUpdateKey:
                return "LocationUpdated"
            case .LocationUpdatesDenied:
                return "com.armstrongapp.LocationUpdatesDenied"
        }
    }
}


@available(iOS 8.0, *)
class LocationManager: NSObject, CLLocationManagerDelegate
{
    private lazy var locationManager:CLLocationManager =
    {
        var locationMgr = CLLocationManager()
        locationMgr.delegate = self
        locationMgr.distanceFilter = 500.0
        locationMgr.activityType = CLActivityType.Fitness
        return locationMgr
    }()
    
    private var lastUpdateTimestamp: NSDate?
    
    
    func requestLocationWhileInUse()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse
            {
                self.locationManager.requestWhenInUseAuthorization()
            }
            else
            {
                self.updateLocationOnMap()
            }
        }
    }
    
    func updateLocationOnMap()
    {
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        switch status
        {
            case .Denied, .Restricted:
                break
//                notify user that will not be able to retrieve current location
            case .AuthorizedWhenInUse:
                if let locationManager: CLLocationManager = manager, location:CLLocation = locationManager.location
                {
                    self.processLocationUpdateOnMap(location)
                }
            
            default:
                break
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
// Handle with alert to user
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let newestLocation:CLLocation = locations.first
        {
            self.processLocationUpdateOnMap(newestLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation)
    {
        self.processLocationUpdateOnMap(newLocation)
    }
    
    func processLocationUpdateOnMap(location:CLLocation)
    {
        let name = LocationUpdateStrings.LocationChanged.name()
        let key = LocationUpdateStrings.LocationUpdateKey.name()
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: self, userInfo: [key : location])
    }
    
}
