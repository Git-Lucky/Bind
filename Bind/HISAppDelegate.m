//
//  HISAppDelegate.m
//  Bind
//
//  Created by Tim Hise on 1/31/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISAppDelegate.h"
#import "HISCollectionViewDataSource.h"
#import "HISBuddy.h"
#import "HISBuddyDetailsViewController.h"
#import "HISTutorialOneViewController.h"

@interface HISAppDelegate ()

@property (strong, nonatomic) HISCollectionViewDataSource *dataSource;

@end

@implementation HISAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    
    // Detect the Notification after a user taps it
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotification) {
        self.dataSource = [[HISCollectionViewDataSource alloc] init];
        [[HISCollectionViewDataSource sharedDataSource] load];
        
        for (HISBuddy *buddy in self.dataSource.buddies) {
            if ([buddy.buddyID isEqualToString:[localNotification.userInfo objectForKey:@"ID"]]) {
                UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
                HISBuddyDetailsViewController *detailsVC = [navController.storyboard instantiateViewControllerWithIdentifier:@"detailsVC"];
                detailsVC.buddy = buddy;
                [navController popToRootViewControllerAnimated:NO];
                [navController pushViewController:detailsVC animated:NO];
                break;
            }
        }
     NSLog(@"Recieved Notification while closed - %@", localNotification);
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //BOOL tutorial = FALSE;
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle: nil];
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"startupTutorial"]) {
//        HISTutorialOneViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"tutorial"];
//        self.window.rootViewController = viewController;
//    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	// Handle the notification when the app is running
    NSLog(@"Recieved Notification while running %@", [notification.userInfo objectForKey:@"ID"]);
    application.applicationIconBadgeNumber = 0;
       
//    self.dataSource = [[HISCollectionViewDataSource alloc] init];
//    [HISCollectionViewDataSource load];
//    
//    for (HISBuddy *buddy in self.dataSource.buddies) {
//        if ([buddy.buddyID isEqualToString:[notification.userInfo objectForKey:@"ID"]]) {
//            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
//            HISBuddyDetailsViewController *detailsVC = [navController.storyboard instantiateViewControllerWithIdentifier:@"detailsVC"];
//            detailsVC.buddy = buddy;
//            //TODO: need to add if statement checking if view is already loaded to handle double back problem
//            [navController popToRootViewControllerAnimated:NO];
//            [navController pushViewController:detailsVC animated:NO];
//            break;
//        }
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
