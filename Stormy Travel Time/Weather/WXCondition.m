//
//  WXCondition.m
//  Stormy Travel Time
//
//  Created by Kevin Armstrong on 8/23/15.
//  Copyright (c) 2015 Armstrong Enterprises. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition
+ (NSDictionary *)imageMap
{
    // 1
    static NSDictionary *_imageMap = nil;
    if (! _imageMap)
    {
        // 2
        _imageMap = @{
                      @"01d" : @"sunny",
                      @"02d" : @"Clouds",
                      @"03d" : @"Clouds",
                      @"04d" : @"Rain",
                      @"09d" : @"Rain",
                      @"10d" : @"Rain",
                      @"11d" : @"Rain",
                      @"13d" : @"Snow",
                      @"50d" : @"Rain",
                      @"01n" : @"Clear",
                      @"02n" : @"cloudy_night",
                      @"03n" : @"cloudy_night",
                      @"04n" : @"Clouds",
                      @"09n" : @"Rain",
                      @"10n" : @"Rain",
                      @"11n" : @"Rain",
                      @"13n" : @"Snow",
                      @"50n" : @"Rain",
                      };
    }
    return _imageMap;
}

- (NSString *)imageName
{
    return [WXCondition imageMap][self.icon];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    // 1
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

// 2
+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSNumber *num,BOOL *success, NSError **error) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed, BOOL *success, NSError **error) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}



@end
