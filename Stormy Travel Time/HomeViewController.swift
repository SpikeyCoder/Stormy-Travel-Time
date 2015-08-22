//
//  HomeViewController.swift
//  Stormy Travel Time
//
//  Created by Armstrong, Kevin M. on 8/14/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import GoogleMaps

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}


class HomeViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var findAddressButton: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var homeViewModel = HomeViewModel()
    
    var didFindMyLocation = false
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    var mapTasks = MapTasks()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613,zoom: 8.0)
        self.registerForNotifications()
        
    }
    
    private func registerForNotifications(){
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
       
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "myLocation")
    }
    
    func findAddressCellPressed(note:NSNotification){
        self.findAddressAction()
    }
    
    
    
    @IBAction func changeTravelMode(sender: AnyObject)
    {
        self.travelModeAction()
    }
    
    func travelModeAction()
    {
        let actionSheet = UIAlertController(title: "Travel Mode", message: "Select travel mode:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let drivingModeAction = UIAlertAction(title: "Driving", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.driving
            self.recreateRoute()
        }
        
        let walkingModeAction = UIAlertAction(title: "Walking", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.walking
            self.recreateRoute()
        }
        
        let bicyclingModeAction = UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.bicycling
            self.recreateRoute()
        }
        
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(drivingModeAction)
        actionSheet.addAction(walkingModeAction)
        actionSheet.addAction(bicyclingModeAction)
        actionSheet.addAction(closeAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    func recreateRoute() {
        if let polyline = routePolyline {
            clearRoute()
            
            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
                
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
    }
    
    func clearRoute() {
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
    
    @IBAction func changeMapType(sender: AnyObject)
    {
        self.mapTypeAction()
    }
    
    func mapTypeAction()
    {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func findAddress(sender: AnyObject)
    {
        self.findAddressAction()
    }
    
    func findAddressAction()
    {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Address?"
        }
        
        let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let address = (addressAlert.textFields![0] as! UITextField).text as String
            
            self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                
                if !success {
                    println(status)
                    
                    if status == "ZERO_RESULTS" {
                        self.showAlertWithMessage("The location could not be found.")
                    }
                }
                else
                {
                    let coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                    self.setuplocationMarker(coordinate)
                }
                
            })
            
        }
        
        
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
        

    }
    
    
    func showAlertWithMessage(message: String) {
        let alertController = UIAlertController(title: "GMapsDemo", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        alertController.addAction(closeAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func createRoute(sender: AnyObject)
    {
        self.createRouteAction()
    }
    
    func createRouteAction()
    {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let origin = (addressAlert.textFields![0] as! UITextField).text as String
            let destination = (addressAlert.textFields![1] as! UITextField).text as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
        
        
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)

    }

    func configureMapAndMarkersForRoute()
    {
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.mapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.mapView
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.mapTasks.destinationAddress
    }
    
    func drawRoute()
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = mapView
        
    }
    
    func displayRouteInfo()
    {
        infoLabel.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = mapView
        
        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        locationMarker.opacity = 0.75
        
        locationMarker.flat = false
        locationMarker.snippet = "The best place on earth."
    }


}
