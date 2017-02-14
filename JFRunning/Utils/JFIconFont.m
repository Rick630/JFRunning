//
//  JFIconFont.m
//  JFRunning
//
//  Created by huangzh on 17/1/23.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFIconFont.h"
#import <CoreText/CoreText.h>

#define kTBCityIconDictionary @{\
@"JFIcon-history":@"\U0000e630",\
@"JFIcon-speed":@"\U0000e605",\
@"JFIcon-time":@"\U0000e621",\
@"JFIcon-run":@"\U0000e600",\
@"JFIcon-run2":@"\U0000e65e",\
@"JFIcon-run3":@"\U0000e632",\
}

@implementation JFIconFont
+ (NSDictionary*)IconDictionary
{
    return kTBCityIconDictionary;
}

+(NSString*)nameToUnicode:(NSString*)name
{
    NSDictionary *nameToUnicode = [self IconDictionary];
    NSString *code = nameToUnicode[name];
    return code ?: name;
}

+ (NSMutableAttributedString *)attributedStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color
{
    NSString *code = [self nameToUnicode:name];
    
    UIFont *font = [UIFont fontWithName:@"JFIcon" size:size];
    
    return [[NSMutableAttributedString alloc] initWithString:code attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
}

+ (UIImage *)iconWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor *)color
{
    NSString *code = [self nameToUnicode:name];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat realSize = size * scale;
    CGFloat imageSize = size * scale;
    UIFont *font = [UIFont fontWithName:@"JFIcon" size:realSize];
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGPoint point = CGPointZero;
    
    if ([code respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
        /**
         * 如果这里抛出异常，请打开断点列表，右击All Exceptions -> Edit Breakpoint -> All修改为Objective-C
         * See: http://stackoverflow.com/questions/1163981/how-to-add-a-breakpoint-to-objc-exception-throw/14767076#14767076
         */
        [code drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: color}];
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGContextSetFillColorWithColor(context, color.CGColor);
        [code drawAtPoint:point withFont:font];
#pragma clang pop
    }
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();

    
    return image;
}
@end
