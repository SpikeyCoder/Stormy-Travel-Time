//
//  HomeViewModel.swift
//  Stormy Travel Time
//
//  Created by Armstrong, Kevin M. on 8/14/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import GoogleMaps

class HomeViewModel: NSObject
{
    var locationManager = CLLocationManager()
    
    var didFindMyLocation = false
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!

    
    
    required override init(){
        super.init()
    }
    
    
    func showAlertWithMessage(message: String) -> UIAlertController
    {
        let alertController = UIAlertController(title: "Location Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alertController.addAction(closeAction)
        
        return alertController
        
    }
    
    func getCoordinate(mapTask:MapTasks) -> CLLocationCoordinate2D
    {
        return CLLocationCoordinate2D(latitude: mapTask.fetchedAddressLatitude, longitude: mapTask.fetchedAddressLongitude)
    }
    
    func setupLocationMarker(mapTasks:MapTasks, mapView:GMSMapView, coordinate: CLLocationCoordinate2D)
    {
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = mapView
        
        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        locationMarker.opacity = 0.75
        
        locationMarker.flat = false
        locationMarker.snippet = "The best place on earth."
    }
    
    func drawRoute(mapTasks:MapTasks, mapView:GMSMapView)
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = mapView
    }
    
    func configureRouteAlert() -> UIAlertController
    {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        return addressAlert
    }
    
    func closeAction() -> UIAlertAction {
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        return closeAction
    }
    
    
    
}
