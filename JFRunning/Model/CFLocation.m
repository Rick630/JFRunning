//
//  CFLocation.m
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "CFLocation.h"

@implementation CFLocation
+ (instancetype)location:(CLLocation *)location
{
    CFLocation *cfLocation = [CFLocation new];
    cfLocation.longitude = location.coordinate.longitude;
    cfLocation.latitude = location.coordinate.latitude;
    cfLocation.timestamp = location.timestamp;
    
    return cfLocation;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeDouble:self.velocity forKey:@"velocity"];
    
    NSTimeInterval timestamp = self.timestamp.timeIntervalSince1970;
    [aCoder encodeDouble:timestamp forKey:@"timestamp"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
    self.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
    self.velocity = [aDecoder decodeDoubleForKey:@"velocity"];
    
    NSTimeInterval timestamp = [aDecoder decodeDoubleForKey:@"timestamp"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    self.timestamp = date;
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"longtitude:%.6f, latitude:%.6f, velocity:%2.fm/s", self.longitude, self.latitude, self.velocity];
}

@end
