//
//  AppDelegate.m
//  SimpleAnimation
//
//  Created by Rescue Mission Software on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//

#import "AppDelegate.h"

#import "CardViewController.h"

#import "StarViewController.h"

#import "ProblemAnimations.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabBarController = [UITabBarController new];
    self.tabBarController.viewControllers = @[[StarViewController new], [CardViewController new], [ProblemAnimations new]];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
