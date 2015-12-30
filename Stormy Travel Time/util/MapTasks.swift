//
//  MapTasks.swift
//  Stormy Travel Time
//
//  Created by Armstrong, Kevin M. on 8/14/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import GoogleMaps

class MapTasks: NSObject
{
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    let apiKey = "&key=AIzaSyA5Kx1uY8RvzsW309wdYhsCYb2an3_Jadk"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    override init() {
        super.init()
    }
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void))
    {
        if let lookupAddress = address
        {
            var geocodeURLString = self.baseURLGeocode + "address=" + lookupAddress + self.apiKey
            geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())!
            
            if let geocodeURL:NSURL = NSURL(string: geocodeURLString){
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let geocodingResultsData = NSData(contentsOfURL: geocodeURL)
                {
                    do{
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData, options: NSJSONReadingOptions.MutableContainers) as? [NSObject:AnyObject]
                        let status = dictionary!["status"] as! String
                        completionHandler(status: status, success: self.getResponseStatus(dictionary!))
                    }
                    catch let error as NSError
                    {
                        print(error)
                    }
                }
            })
            }
        }
        else
        {
            completionHandler(status: "No valid address.", success: false)
        }

    }
    
    func getResponseStatus(dictionary: [NSObject:AnyObject]) -> Bool
    {
        // Get the response status.
        let status = dictionary["status"] as! String
        
        if status == "OK"
        {
            let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
            self.lookupAddressResults = allResults[0]
            
            // Keep the most important values.
            self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
            let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
            self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
            self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
            return true
        }
        else
        {
            return false
        }
    }
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)) {
        if let originLocation = origin, destinationLocation = destination
        {
                let directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                guard let directionsURLStringCleansed: String = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {return }
                var directionsURLMutableString = directionsURLStringCleansed
                if let routeWaypoints = waypoints
                {
                    directionsURLMutableString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints
                    {
                        directionsURLMutableString += "|" + waypoint
                    }
                }
                
                let directionsURL = NSURL(string: directionsURLMutableString)
                  do {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                        let directionsData = NSData(contentsOfURL: directionsURL!), dictionary: Dictionary<NSObject, AnyObject> = (try! NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers)) as! Dictionary<NSObject, AnyObject>
                    
                    if let status = dictionary["status"] as? String where status == "OK"
                    {
                        self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                        self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                        
                        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                        
                        let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                        self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                        
                        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                        self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                        self.fetchedAddressLatitude = self.destinationCoordinate.latitude
                        self.fetchedAddressLongitude = self.destinationCoordinate.longitude
                        
                        self.originAddress = legs[0]["start_address"] as! String
                        self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                        
                        self.calculateTotalDistanceAndDuration()
                        
                        completionHandler(status: status, success: true)
                    }
                    else
                    {
                        if let status = dictionary["status"] as? String
                        {
                            completionHandler(status: status, success: false)
                        }
                    }
                        
                })  }catch let error as NSError{
                    print(error)
                    completionHandler(status: "", success: false)
                }
        }
        else
        {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    func calculateTotalDistanceAndDuration()
    {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        self.totalDistanceInMeters = 0
        self.totalDurationInSeconds = 0
        
        for leg in legs
        {
            self.totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            self.totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        self.setFormattedDistanceString()
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        let timeArray = ["\(days) days, ", "\(remainingHours) hours, ", "\(remainingMins) mins, ", "\(remainingSecs) secs"]
        
        totalDuration = self.getFormattedInfoTimeString(timeArray)
    }
    
    func setFormattedDistanceString()
    {
        let distanceInKilometers: Double = Double(self.totalDistanceInMeters)
        let distanceInMiles: Double = Double(distanceInKilometers * 0.000621371 )
        self.totalDistance = "Total Distance: \(distanceInMiles.formatted) miles"
    }
    
    func getFormattedInfoTimeString(timeArray:[String]) -> String
    {
        var infoTimeString = "Duration: "
        for timeUnit in timeArray
        {
            if timeUnit.rangeOfString("secs") == nil
            {
                if timeUnit.rangeOfString("0") == nil
                {
                    infoTimeString += timeUnit
                }
            }
            else
            {
                infoTimeString += timeUnit
            }
        }
        return infoTimeString
    }
    
}

extension Double
{
    var formatted:String
        {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.stringFromNumber(self)!
    }
}

