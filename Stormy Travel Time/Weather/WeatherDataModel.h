//
//  WeatherDataModel.h
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 12/25/15.
//  Copyright © 2015 Armstrong Enterprises. All rights reserved.
//
@import CoreLocation;
@import Foundation;
#import "ReactiveCocoa.h"
#import <Foundation/Foundation.h>

@interface WeatherDataModel : NSObject

+ (instancetype)sharedManager;

@property(nonatomic) NSString * temp;
@property(nonatomic) NSString * conditions;
@end
