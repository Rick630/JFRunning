//
//  JFPublic.h
//  JFRunning
//
//  Created by huangzh on 17/1/23.
//  Copyright © 2017年 RIck. All rights reserved.
//

#ifndef JFPublic_h
#define JFPublic_h


#endif /* JFPublic_h */
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#define APP_DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

#import "JFIconFont.h"
#import "AppDelegate.h"
