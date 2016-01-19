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


class HomeViewController: UIViewController, UINavigationBarDelegate  {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var findAddressButton: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var weatherIconBottomConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var weatherIconRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    var locationManager = WXManager.sharedManager()
    
    var homeViewModel = HomeViewModel()
    
    var didFindMyLocation = false
    
    var waypointsArray: Array<String> = []
    
    var myLocation = CLLocation()
    
    var travelMode = TravelModes.driving
    
    var mapTasks = MapTasks()
    
    var weatherData = WeatherDataController()
    
    var locationMarker: GMSMarker!
    
    var manager: WXManager!
    
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
     
        self.manager = WXManager.sharedManager()
        
        self.registerForNotifications()
        
    }
    
    private func registerForNotifications()
    {
        mapView.addObserver(self, forKeyPath: "locationChanged", options: NSKeyValueObservingOptions.New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "findAddressCellPressed:", name: "com.StormyTravelTime.findAddress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeMapTypePressed:", name: "com.StormyTravelTime.mapType", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createRoutePressed:", name: "com.StormyTravelTime.directions", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeTravelModePressed:", name: "com.StormyTravelTime.travelType", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationAuthorizedByUser:",name:LocationUpdateStrings.LocationChanged.name(),object: nil)
       
    }

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "locationChanged")
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
        if self.routePolyline != nil
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.homeViewModel.clearRoute()
                self.mapTasks.getDirections(self.mapTasks.originAddress, destination: self.mapTasks.destinationAddress, waypoints: self.waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
                    
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
                    if self.infoLabel.text!.rangeOfString("Total Distance") == nil
                    {
                       
                        let coordinate = self.homeViewModel.getCoordinate(self.mapTasks)
                        self.weatherData.weatherAtLocation(coordinate, completion: { (tempString) -> Void in
                            self.infoLabel.text = tempString
                           
                        })
                        
                    }
                     self.revealWeatherIcon()
                })
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
            let origin = (addressAlert.textFields![0] ).text! as String
            let destination = (addressAlert.textFields![1] ).text! as String
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
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
        }

        let closeAction = self.homeViewModel.closeAction()
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)

    }
    
    func displayRouteInfo()
    {
        let coordinate = self.homeViewModel.getCoordinate(self.mapTasks)
        self.weatherData.weatherAtDestination(Int(self.mapTasks.totalDurationInSeconds/3600), coordinate: coordinate) { (tempString) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.infoLabel.text = self.mapTasks.totalDistance + "\n" + self.mapTasks.totalDuration + "\n" + tempString
            }
        }
    }
    
    func locationAuthorizedByUser(note: NSNotification)
    {
        if let info:[NSObject:AnyObject] = note.userInfo, location = info[LocationUpdateStrings.LocationChangedKey.name()] as? CLLocation
        {
            print(location.coordinate)
            mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as? CLLocation where !didFindMyLocation
        {
            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }
    
    func revealWeatherIcon()
    {
        self.weatherIcon.image = self.homeViewModel.setWeatherImage(self.weatherData.weatherCondition)
        self.weatherIcon.hidden = false
        self.infoLabel.hidden = false
        self.revealViewController().revealToggleAnimated(true)
        self.view.layoutIfNeeded()
    }
    
    func hideWeatherInfo(){
        self.weatherIcon.hidden = true
        self.infoLabel.hidden = true
    }
}
