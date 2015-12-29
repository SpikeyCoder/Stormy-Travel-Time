//
//  WXManager.h
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/23/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import "ReactiveCocoa.h"
#import "WXCondition.h"

@interface WXManager : NSObject
<CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
