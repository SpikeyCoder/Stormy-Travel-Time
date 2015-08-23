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


class HomeViewController: UIViewController, CLLocationManagerDelegate, UINavigationBarDelegate  {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var findAddressButton: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var locationManager = CLLocationManager()
    
    var homeViewModel = HomeViewModel()
    
    var didFindMyLocation = false
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    var mapTasks = MapTasks()
    
    var weatherData = WeatherDataController()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
     
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613,zoom: 8.0)
        self.registerForNotifications()
        
    }
    
    private func registerForNotifications(){
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "findAddressCellPressed:", name: "com.StormyTravelTime.findAddress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMapTypePressed:", name: "com.StormyTravelTime.mapType", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createRoutePressed:", name: "com.StormyTravelTime.directions", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTravelModePressed:", name: "com.StormyTravelTime.travelType", object: nil)
       
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "myLocation")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func findAddressCellPressed(note:NSNotification){
        self.findAddressAction()
    }
    
    func changeTravelModePressed(note:NSNotification)
    {
        self.travelModeAction()
    }
    
    func travelModeAction()
    {
        let actionSheet = UIAlertController(title: "Travel Mode", message: "Select travel mode:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let drivingModeAction = UIAlertAction(title: "Driving", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.driving
            self.recreateRoute()
             self.revealViewController().revealToggleAnimated(true)
        }
        
        let walkingModeAction = UIAlertAction(title: "Walking", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.walking
            self.recreateRoute()
             self.revealViewController().revealToggleAnimated(true)
        }
        
        let bicyclingModeAction = UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.bicycling
            self.recreateRoute()
             self.revealViewController().revealToggleAnimated(true)
        }
        
        
        let closeAction = self.homeViewModel.closeAction()
        
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
                    self.homeViewModel.drawRoute(self.mapTasks, mapView: self.mapView)
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
        }
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
    
    func changeMapTypePressed(note:NSNotification){
        self.mapTypeAction()
    }
    
    func mapTypeAction()
    {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeNormal
             self.revealViewController().revealToggleAnimated(true)
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeTerrain
             self.revealViewController().revealToggleAnimated(true)
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeHybrid
             self.revealViewController().revealToggleAnimated(true)
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
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
                        var alert = self.homeViewModel.showAlertWithMessage("The location could not be found.")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    let coordinate = self.homeViewModel.getCoordinate(self.mapTasks)
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                    self.homeViewModel.setupLocationMarker(self.mapTasks, mapView: self.mapView, coordinate: coordinate)
                }
                
            })
             self.revealViewController().revealToggleAnimated(true)
            if self.infoLabel.text == nil
            {
                self.infoLabel.text = self.weatherData.weatherAtLocation()
            }
        }
        
        let closeAction = self.homeViewModel.closeAction()
        
        addressAlert.addAction(findAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
    }
   
//    MARK : - Create Route Action
    
    func createRoutePressed(note: NSNotification)
    {
        self.createRouteAction()
    }
    
    func createRouteAction()
    {
        let addressAlert = self.homeViewModel.configureRouteAlert()
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let origin = (addressAlert.textFields![0] as! UITextField).text as String
            let destination = (addressAlert.textFields![1] as! UITextField).text as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.homeViewModel.drawRoute(self.mapTasks, mapView: self.mapView)
                    self.displayRouteInfo()
                }
                else {
                    println(status)
                }
            })
            self.revealViewController().revealToggleAnimated(true)
        }

        let closeAction = self.homeViewModel.closeAction()
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
    
    func displayRouteInfo()
    {
        infoLabel.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration + "\n" + self.weatherData.weatherAtDestination()
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
}
