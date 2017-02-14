//
//  JFRecordShowModel.m
//  JFRunning
//
//  Created by huangzh on 17/1/22.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFRecordShowModel.h"
#import <UIKit/UIKit.h>

@interface JFRecordShowModel ()

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableDictionary *map;

@end

@implementation JFRecordShowModel

- (NSMutableArray *)list
{
    if(_list) return _list;
    
    _list = [NSMutableArray new];
    return _list;
}

- (NSMutableDictionary *)map
{
    if(_map) return _map;
    
    _map = [NSMutableDictionary new];
    return _map;
}

- (void)appendData:(NSArray<CFJourney *> *)journeys
{
    NSInteger thisYear = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]].year;
    for (CFJourney *journey in journeys)
    {
        NSDateComponents *component = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:journey.startTime];
        
        NSString *key = @"";
        if(component.year == thisYear)
        {
            key = [NSString stringWithFormat:@"%d月", (int)component.month];
        }
        else
        {
            key = [NSString stringWithFormat:@"%d年%d月", (int)component.year,(int)component.month];
        }

        NSMutableArray *sectionList = self.map[key];
        if(sectionList == nil)
        {
            sectionList = [NSMutableArray new];
            self.map[key] = sectionList;
            [self.list addObject:key];
        }
        
        [sectionList addObject:journey];
    }
}

- (void)clear
{
    [self.list removeAllObjects];
    [self.map removeAllObjects];
}

- (void)removeJourneyAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = self.list[indexPath.section];
    NSMutableArray *sectionList = self.map[sectionTitle];
    
    [sectionList removeObjectAtIndex:indexPath.row];
    if(sectionList.count == 0)
    {
        self.map[sectionTitle] = nil;
        [self.list removeObjectAtIndex:indexPath.section];
    }
}

#pragma mark - getter
- (NSInteger)numberOfSections
{
    return self.list.count;
}

- (NSInteger)numberOfRowsForSection:(NSInteger)section
{
    NSString *sectionTitle = self.list[section];
    NSMutableArray *sectionList = self.map[sectionTitle];
    
    return sectionList.count;
}

- (NSString *)titleOfSection:(NSInteger)section
{
    return self.list[section];
}

- (CFJourney *)journeyOfIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = self.list[indexPath.section];
    NSMutableArray *sectionList = self.map[sectionTitle];
    
    return sectionList[indexPath.row];
}
@end
