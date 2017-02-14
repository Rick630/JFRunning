//
//  AppDelegate.m
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "AppDelegate.h"
#import "JFPublic.h"

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self setupIcon];
    [self setupNavigationTheme];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - setup
- (void)setupIcon
{
    UITabBarController *tabBarVC = (UITabBarController *)self.window.rootViewController;
    tabBarVC.tabBar.tintColor = HexRGBAlpha(0x262626, 0.9);
    
    NSArray *icons = @[@"JFIcon-run", @"JFIcon-history"];
    
    int i=0;
    for(UITabBarItem *item in tabBarVC.tabBar.items)
    {
        item.image = [JFIconFont iconWithName:icons[i] fontSize:25 color:HexRGB(0x262626)];
        i++;
    }
}

- (void)setupNavigationTheme
{
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = HexRGBAlpha(0x262626, 0.9);
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:HexRGBAlpha(0x262626, 0.9)};
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
        [UINavigationBar appearance].translucent = YES;
}

@end
