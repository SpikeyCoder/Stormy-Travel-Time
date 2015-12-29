//
//  WeatherDataModel.m
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 12/25/15.
//  Copyright © 2015 Armstrong Enterprises. All rights reserved.
//

#import "WeatherDataModel.h"
#import "WXManager.h"

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
        [self performRACObservation];
    }
    return self;
}

-(void)performRACObservation
{
    [[RACObserve([WXManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         self.temp = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         self.conditions = [newCondition.condition capitalizedString];

     }];
    
}

@end
