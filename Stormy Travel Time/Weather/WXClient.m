//
//  WXClient.m
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 12/25/15.
//  Copyright © 2015 Armstrong Enterprises. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString * apiKey;

@end

@implementation WXClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
        self.apiKey = @"8a9a4b36a224b8b0d349e971d321541f";
    }
    return self;
}

@end
