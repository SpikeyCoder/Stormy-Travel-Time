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
    @IBOutlet weak var weatherIconBottomConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var weatherIconRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    var locationManager = CLLocationManager()
    
    var homeViewModel = HomeViewModel()
    
    var didFindMyLocation = false
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    var mapTasks = MapTasks()
    
    var weatherData = WeatherDataController()
    
    var locationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil
        {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.homeViewModel.configureRevealVC(self.revealViewController())
            self.weatherIcon.hidden = true
        }
     
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613,zoom: 8.0)
        self.registerForNotifications()
        
    }
    
    private func registerForNotifications()
    {
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "findAddressCellPressed:", name: "com.StormyTravelTime.findAddress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMapTypePressed:", name: "com.StormyTravelTime.mapType", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createRoutePressed:", name: "com.StormyTravelTime.directions", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTravelModePressed:", name: "com.StormyTravelTime.travelType", object: nil)
       
    }

    deinit
    {
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
            self.dismissAndRecreateRoute()
        }
        
        let walkingModeAction = UIAlertAction(title: "Walking", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.walking
            self.dismissAndRecreateRoute()
        }
        
        let bicyclingModeAction = UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.travelMode = TravelModes.bicycling
            self.dismissAndRecreateRoute()
        }
        
        
        let closeAction = self.homeViewModel.closeAction()
        
        actionSheet.addAction(drivingModeAction)
        actionSheet.addAction(walkingModeAction)
        actionSheet.addAction(bicyclingModeAction)
        actionSheet.addAction(closeAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func dismissAndRecreateRoute()
    {
        self.recreateRoute()
        self.revealViewController().revealToggleAnimated(true)
    }
    
    func recreateRoute()
    {
        if let polyline = routePolyline
        {
            self.homeViewModel.clearRoute()
            
            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
                
                if success
                {
                    self.homeViewModel.configureMapAndMarkersForRoute(self.mapTasks, mapView: self.mapView)
                    self.homeViewModel.drawRoute(self.mapTasks, mapView: self.mapView)
                    self.displayRouteInfo()
                }
                else
                {
                    print(status)
                }
            })
        }
    }
    
    func changeMapTypePressed(note:NSNotification)
    {
        self.mapTypeAction()
    }
    
    func mapTypeAction()
    {
        let actionSheet = self.homeViewModel.getMapTypeAlert()
        
        let normalMapTypeAction = self.homeViewModel.getNormalMap(self.mapView, revealVC: self.revealViewController())
        
        let terrainMapTypeAction = self.homeViewModel.getTerrainMap(self.mapView, revealVC: self.revealViewController())
        
        let hybridMapTypeAction = self.homeViewModel.getHybridMap(self.mapView, revealVC: self.revealViewController())
        
        let cancelAction = self.homeViewModel.closeAction()
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func findAddressAction()
    {
        let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler{ (textField) -> Void in
            textField.placeholder = "Address?"
        }
        
        let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if let addressTextFields:[UITextField] = addressAlert.textFields, addressTextField:UITextField = addressTextFields[0], address:String = addressTextField.text
            {
                        self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
                    
                    if !success
                    {
                        print(status)
                        
                        if status == "ZERO_RESULTS"
                        {
                            let alert = self.homeViewModel.showAlertWithMessage("The location could not be found.")
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
            }
            
            
            if self.infoLabel.text!.rangeOfString("Total Distance") == nil
            {
                self.infoLabel.text = self.weatherData.weatherAtLocation()
            }
            self.revealWeatherIcon()
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
            let origin = (addressAlert.textFields![0] as! UITextField).text! as String
            let destination = (addressAlert.textFields![1] as! UITextField).text! as String
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success
                {
                    self.homeViewModel.configureMapAndMarkersForRoute(self.mapTasks, mapView: self.mapView)
                    self.homeViewModel.drawRoute(self.mapTasks, mapView: self.mapView)
                    self.displayRouteInfo()
                }
                else
                {
                    print(status)
                }
            })
            self.weatherIconBottomConstraint.constant = 0
            self.weatherIconRightConstraint.constant = 70
            self.revealWeatherIcon()
        }

        let closeAction = self.homeViewModel.closeAction()
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)

    }
    
    func displayRouteInfo()
    {
        infoLabel.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration + "\n" + self.weatherData.weatherAtDestination()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            mapView.myLocationEnabled = true
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if !didFindMyLocation
        {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    func revealWeatherIcon()
    {
        self.weatherIcon.image = self.homeViewModel.setWeatherImage(self.weatherData.weatherCondition)
        self.weatherIcon.hidden = false
        self.revealViewController().revealToggleAnimated(true)
        self.view.layoutIfNeeded()
    }
}
