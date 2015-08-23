//
//  WeatherDataController.swift
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/16/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherDataController: NSObject {
    var session:NSURLSession!
    var degreesAtDestination = 75.0
    var weatherCondition = "Sunny"
    
    required override init()
    {
        var config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: config)
        super.init()
    }
   
    
    func weatherAtDestination() -> String {
        return "Weather Upon Arrival: \(degreesAtDestination)\u{00B0} F"
    }
    
    func weatherAtLocation() -> String {
        return "Current Weather: \(degreesAtDestination)\u{00B0} F"
    }
    
    func fetchJSONFromURL(url:NSURL) -> RACSignal
    {
        println("Fetching: \(url.absoluteString)")
        var data:NSData
        var error:NSError!
        var subscriber:RACDisposable!
        var response:NSURLResponse!
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            var dataTask = self.session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if error == nil
                {
                    var jsonError:NSError?
                    var json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &jsonError) as? NSDictionary
                    
                    if let err = jsonError
                    {
                        println("json error: \(err)")
                        subscriber.sendError(err)
                    }
                    else
                    {
                        subscriber.sendNext(json)
                    }
                }
                else
                {
                    subscriber.sendError(error)
                }
                subscriber.sendCompleted()
                
            })
            dataTask.resume()
            return RACDisposable(block: { () -> Void in
                dataTask.cancel()
            })
        })
    }
    
    func fetchCurrentConditionsForLocation(coordinate:CLLocationCoordinate2D)-> RACSignal
    {
        let urlString = NSString(format: "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude)
        let url = NSURL(string: urlString as String)
        
        var signal:RACSignal! = self.fetchJSONFromURL(url!)
      
        var condition:WXCondition!
        var json:AnyObject!
        var signal2: AnyObject! = MTLJSONAdapter.modelOfClass(WXCondition.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil)
        return signal.map({ (json) -> AnyObject! in
            return signal2
        })
        
    }
    
    func fetchHourlyForecastForLocation(coordinate:CLLocationCoordinate2D) -> RACSignal
    {
        let urlString = NSString(format: "http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12", coordinate.latitude, coordinate.longitude)
        let url = NSURL(string: urlString as String)
        
        var signal:RACSignal! = self.fetchJSONFromURL(url!)
        
        var condition:WXCondition!
        var json:AnyObject!
        var signal2: AnyObject! = MTLJSONAdapter.modelOfClass(WXCondition.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil)
        return signal.map(
            { (json) -> AnyObject! in
                if let jsonObj = json as? [NSObject : AnyObject]
                {
                    var list:RACSequence = jsonObj["list"]!.rac_sequence
                    return list.map({ (json) -> AnyObject! in
                        return signal2
                    })

                }
                return signal2
        })

    }
    func fetchDailyForecastForLocation(coordinate:CLLocationCoordinate2D) -> RACSignal
    {
        let urlString = NSString(format: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7", coordinate.latitude, coordinate.longitude)
        let url = NSURL(string: urlString as String)
        
        var signal:RACSignal! = self.fetchJSONFromURL(url!)
        
        var condition:WXCondition!
        var json:AnyObject!
        var signal2: AnyObject! = MTLJSONAdapter.modelOfClass(WXDailyForecast.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil)
        return signal.map(
            { (json) -> AnyObject! in
                if let jsonObj = json as? [NSObject : AnyObject]
                {
                    var list:RACSequence = jsonObj["list"]!.rac_sequence
                    return list.map({ (json) -> AnyObject! in
                        return signal2
                    })
                }
                return signal2
        })
    }
}
