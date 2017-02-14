//
//  JFRecordShowModel.h
//  JFRunning
//
//  Created by huangzh on 17/1/22.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFJourney.h"

@interface JFRecordShowModel : NSObject

@property (readonly, nonatomic, assign) NSInteger numberOfSections;
- (NSInteger)numberOfRowsForSection:(NSInteger)section;
- (NSString *)titleOfSection:(NSInteger)section;
- (CFJourney *)journeyOfIndexPath:(NSIndexPath *)indexPath;

- (void)appendData:(NSArray<CFJourney *> *)journeys;
- (void)removeJourneyAtIndexPath:(NSIndexPath *)indexPath;

- (void)clear;
@end
