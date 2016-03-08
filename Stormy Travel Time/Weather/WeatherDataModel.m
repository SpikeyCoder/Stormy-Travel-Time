//
//  WeatherDataModel.m
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 12/25/15.
//  Copyright © 2015 Armstrong Enterprises. All rights reserved.
//

#import "WeatherDataModel.h"

@implementation WeatherDataModel

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}


@end
