//
//  CFJourney.h
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFLocation.h"
@interface CFJourney : NSObject 

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *finishTime;
@property (nonatomic, copy) NSArray<CFLocation *> *locations;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, assign) double maxV;
@property (nonatomic, assign) double minV;
@end
