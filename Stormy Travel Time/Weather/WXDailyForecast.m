//
//  WXDailyForecast.m
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/23/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3
    return paths;
}


@end
