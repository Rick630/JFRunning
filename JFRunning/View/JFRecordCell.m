//
//  JFRecordCell.m
//  JFRunning
//
//  Created by huangzh on 17/1/20.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFRecordCell.h"
#import "JFPublic.h"

@interface JFRecordCell ()
@property (weak, nonatomic) IBOutlet UILabel *labMD;
@property (weak, nonatomic) IBOutlet UILabel *labDistance;
@property (weak, nonatomic) IBOutlet UILabel *labUnit;
@property (weak, nonatomic) IBOutlet UILabel *labDuration;
@property (weak, nonatomic) IBOutlet UILabel *labSpeed;

@property (weak, nonatomic) IBOutlet UIImageView *icoView;
@end

@implementation JFRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.icoView.layer.cornerRadius = CGRectGetWidth(self.icoView.frame)/2.0;
    self.icoView.layer.masksToBounds = YES;
    self.labDistance.font = [UIFont fontWithName:@"DINOT-Bold" size:45];
    self.icoView.image = [JFIconFont iconWithName:@"JFIcon-run3" fontSize:CGRectGetWidth(self.icoView.frame) color:HexRGBAlpha(0x262626, 0.9)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setJourney:(CFJourney *)journey
{
    _journey = journey;
    
    
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.journey.startTime];
    
    self.labMD.text = [NSString stringWithFormat:@"%d号", (int)component.day];
    
    BOOL not1K = journey.distance < 1000;
    double distance = journey.distance;
    if(not1K)
    {
        self.labDistance.text = [NSString stringWithFormat:@"%.1f", distance];
        self.labUnit.text = @"m";        
    }
    else
    {
        self.labDistance.text = [NSString stringWithFormat:@"%.1f", distance/1000.0];
        self.labUnit.text = @"km";
    }

    long offset = [journey.finishTime timeIntervalSinceDate:journey.startTime];
    long speed = offset/(distance/1000);
    
    self.labDuration.attributedText = [self attDuration:[self durationStrWithTimeOffset:offset]];
    self.labSpeed.attributedText = [self attSpeed:[self speedStrWithTimeOffset:speed]];
}

- (NSString *)durationStrWithTimeOffset:(long)offset
{
    NSInteger hourUnit = 60 * 60;
    long hour = offset/hourUnit;
    long minute, second;
    minute = 0; second = 0;
    
    NSInteger hourLeft = offset%hourUnit;
    if(hourLeft)
    {
        NSInteger minuteUnit = 60;
        minute = hourLeft/minuteUnit;
        NSInteger minuteLeft = hourLeft%minuteUnit;
        
        if(minuteLeft)
        {
            second = minuteLeft;
        }
    }
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minute, second];
}

- (NSString *)speedStrWithTimeOffset:(long)offset
{
    long minute, second;
    minute = 0; second = 0;
    
    NSInteger minuteUnit = 60;
    minute = offset/minuteUnit;
    NSInteger minuteLeft = offset%minuteUnit;
    
    if(minuteLeft)
    {
        second = minuteLeft;
    }
    
    return [NSString stringWithFormat:@"%02ld'%02ld''", minute, second];
}
- (NSAttributedString *)attDuration:(NSString *)duration
{
    NSMutableAttributedString *attDuration = [JFIconFont attributedStringWithName:@"JFIcon-time" fontSize:14 color:HexRGBAlpha(0x262626, 0.3)];
    [attDuration appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", duration?duration:@"" ]attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HexRGBAlpha(0x262626, 0.9)}]];
    
    return attDuration;
}

- (NSAttributedString *)attSpeed:(NSString *)speed
{
    NSMutableAttributedString *attDuration = [JFIconFont attributedStringWithName:@"JFIcon-speed" fontSize:14 color:HexRGBAlpha(0x262626, 0.3)];
    [attDuration appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", speed?speed:@"" ]attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: HexRGBAlpha(0x262626, 0.9)}]];
    
    return attDuration;
}

@end
