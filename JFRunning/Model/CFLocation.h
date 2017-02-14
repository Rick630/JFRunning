//
//  CFLocation.h
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CFLocation : NSObject <NSCoding>

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) double velocity;

+ (instancetype)location:(CLLocation *)location;

@end
