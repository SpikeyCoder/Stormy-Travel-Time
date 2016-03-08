//
//  WeatherDataController.swift
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/16/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit
import CoreLocation

typealias WeatherCompletion = (tempString:String) -> Void

class WeatherDataController: NSObject {
    
    var degreesAtDestination = 75.0
    var weatherCondition = "Sunny"
    let apiKey = "8a9a4b36a224b8b0d349e971d321541f"
    
    required override init()
    {
        super.init()
    }
    
    func weatherAtDestination(duration:Int, coordinate: CLLocationCoordinate2D, completion:WeatherCompletion)
    {
        let urlString = NSString(format: "http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12&APPID=8a9a4b36a224b8b0d349e971d321541f", coordinate.latitude, coordinate.longitude)
        
        if let url:NSURL = NSURL(string: urlString as String)
        {
            self.fetchWeatherDataFromURL(url) { (jsonResult) -> Void in
                if let weatherList = jsonResult["list"] as? [AnyObject]
                {
                    let temp = self.getTempFromList(weatherList, hourNumber: duration)
                    completion(tempString: "Weather Upon Arrival: \(temp)\u{00B0} F")
                }
            }
        }
    }
    
    func getTempFromList(list:[AnyObject], hourNumber:Int) -> Double
    {
        let hour = hourNumber < 13 ? hourNumber : 12
        
        if let weatherForHour = list[hour] as? [NSObject:AnyObject], mainWeather = weatherForHour["main"] as? [NSObject:AnyObject], temp = mainWeather["temp"] as? Double
        {
            self.setWeatherConditionsForHour(weatherForHour)
            return temp
        }
        return 75.0
    }
    
    func setWeatherConditionsForHour(weatherForHour:[NSObject:AnyObject])
    {
        if let weather = weatherForHour["weather"] as? [NSObject:AnyObject], condition = weather["main"] as? String
        {
            self.weatherCondition = condition
        }
    }
    
    func weatherAtLocation(coordinate: CLLocationCoordinate2D, completion:WeatherCompletion)
    {
        let urlString = NSString(format: "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial&cnt=7&APPID=8a9a4b36a224b8b0d349e971d321541f", coordinate.latitude, coordinate.longitude)

        if let url:NSURL = NSURL(string: urlString as String)
        {
            self.fetchWeatherDataFromURL(url) { (jsonResult) -> Void in
                if let mainWeather = jsonResult["main"] as? [NSObject:AnyObject]
                {
                  completion(tempString: "Current Weather: \(mainWeather["temp"]!)\u{00B0} F")
                }
            }
        }
    }
    
    func fetchWeatherDataFromURL(url:NSURL, completion:(jsonResult:[NSObject: AnyObject])-> Void)
    {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url)
            { (data, response, error) -> Void in
                if let dataFromURL:NSData = data,
                    jsonResult = try? NSJSONSerialization.JSONObjectWithData(dataFromURL, options: NSJSONReadingOptions.MutableContainers) as? [NSObject:AnyObject],
                    json = jsonResult
                {
                    completion(jsonResult: json)
                }
        }
        task.resume()
    }
}
