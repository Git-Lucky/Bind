//
//  HISLocalNotificationController.m
//  Bind
//
//  Created by Tim Hise on 2/6/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISLocalNotificationController.h"

@implementation HISLocalNotificationController

- (void)scheduleNotificationsForBuddy:(HISBuddy *)buddy;
{   //want to go every two weeks but repeatInterval is only by set amount such as monthly so I set up two two weeks apart
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [self addNumberOfDays:14 toDate:buddy.dateOfLastInteraction];
    notification.repeatInterval = NSMonthCalendarUnit;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat:@"It's been a while since you last connected with %@", buddy.name];
    notification.alertAction = NSLocalizedString(@"View", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber += 1;
    
    [buddy.notifications addObject:notification];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    UILocalNotification *notification2 = [[UILocalNotification alloc] init];
    notification2.fireDate = [self addNumberOfDays:28 toDate:buddy.dateOfLastInteraction];
    notification2.repeatInterval = NSMonthCalendarUnit;
    notification2.timeZone = [NSTimeZone defaultTimeZone];
    notification2.alertBody = [NSString stringWithFormat:@"It's been a while since you last connected with %@", buddy.name];
    notification2.alertAction = NSLocalizedString(@"View", nil);
    notification2.soundName = UILocalNotificationDefaultSoundName;
    notification2.applicationIconBadgeNumber += 1;
    
    [buddy.notifications addObject:notification2];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification2];
}

- (NSDate *)addNumberOfDays:(NSInteger)days toDate:(NSDate *)date
{
    return [date dateByAddingTimeInterval:60*60*24*days];
}

@end
