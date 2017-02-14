//
//  CFJourney.h
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFLocation.h"
@interface CFRun : NSObject 

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *finishTime;
@property (nonatomic, copy) NSArray<CFLocation *> *locations;

@end
