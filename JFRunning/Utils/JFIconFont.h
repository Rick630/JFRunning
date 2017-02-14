//
//  JFIconFont.h
//  JFRunning
//
//  Created by huangzh on 17/1/23.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFIconFont : NSObject
+ (UIImage *)iconWithName:(NSString*)name fontSize:(CGFloat)size color:(UIColor*)color;
+ (NSMutableAttributedString *)attributedStringWithName:(NSString *)name fontSize:(CGFloat)size color:(UIColor*)color;
@end
