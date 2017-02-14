//
//  WGS84TOGCJ02.h
//  JFRunning
//
//  Created by huangzh on 17/1/20.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface WGS84TOGCJ02 : NSObject
//转GCJ-02
+ (CLLocationCoordinate2D)transformToMars:(CLLocationCoordinate2D)location ;
@end
