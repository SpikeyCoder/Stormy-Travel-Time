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
    
    func clearRoute()
    {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
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
    
    func getMapTypeAlert() -> UIAlertController {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        return actionSheet
    }
    
    func getNormalMap(mapView:GMSMapView, revealVC:SWRevealViewController) -> UIAlertAction
    {
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            mapView.mapType = kGMSTypeNormal
            revealVC.revealToggleAnimated(true)
        }
        return normalMapTypeAction

    }
    
    func getTerrainMap(mapView:GMSMapView, revealVC:SWRevealViewController) -> UIAlertAction
    {
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            mapView.mapType = kGMSTypeTerrain
            revealVC.revealToggleAnimated(true)
        }
        return terrainMapTypeAction
        
    }
    
    func getHybridMap(mapView:GMSMapView, revealVC:SWRevealViewController) -> UIAlertAction
    {
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            mapView.mapType = kGMSTypeHybrid
            revealVC.revealToggleAnimated(true)
        }
        return hybridMapTypeAction
        
    }
    
    func configureRevealVC(revealVC:SWRevealViewController)
    {
        revealVC.bounceBackOnLeftOverdraw = true
        revealVC.bounceBackOnOverdraw = true
        revealVC.stableDragOnLeftOverdraw = true
        revealVC.stableDragOnOverdraw = true
    }
    
    func setWeatherImage(weatherCondition:String) -> UIImage
    {
        let weatherString = weatherCondition.lowercaseString
        let weatherIcon = UIImage(named: weatherString)
        return weatherIcon!
    }
}


