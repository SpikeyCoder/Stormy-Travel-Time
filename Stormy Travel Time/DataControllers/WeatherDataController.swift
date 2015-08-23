//
//  WeatherDataController.swift
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/16/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

import UIKit

class WeatherDataController: NSObject {
    required override init(){
        super.init()
    }
    
    var degreesAtDestination = 0.0
    var weatherCondition = "Cloudy"
    
    func weatherAtDestination() -> String {
        return "Weather Upon Arrival: \(degreesAtDestination)\u{00B0} F, \(weatherCondition)"
    }
    
    func weatherAtLocation() -> String {
        return "Current Weather: \(degreesAtDestination)\u{00B0} F, \(weatherCondition)"
    }
}
