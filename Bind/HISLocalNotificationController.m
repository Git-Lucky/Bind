//
//  HISLocalNotificationController.m
//  Bind
//
//  Created by Tim Hise on 2/6/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISLocalNotificationController.h"

@interface HISLocalNotificationController ()

@property (strong, nonatomic) NSMutableArray *alertMessages;
@property (strong, nonatomic) NSString *buddyName;

@end

@implementation HISLocalNotificationController

- (void)scheduleNotificationsForBuddy:(HISBuddy *)buddy
{
    //want to go every two weeks but repeatInterval is only by set amount such as monthly so I set up two two weeks apart
    self.buddyName = buddy.name;
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [self addNumberOfDays:14 toDate:buddy.dateOfLastInteraction];
    notification.repeatInterval = NSMonthCalendarUnit;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    int randomMessagePosition = arc4random() % [self.alertMessages count];
    notification.alertBody = [self.alertMessages objectAtIndex:randomMessagePosition];
    notification.alertAction = NSLocalizedString(@"Take me to their beautiful face", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    NSString *userInfoString = [buddy.name stringByAppendingString:[NSString stringWithFormat:@"%@", buddy.dateOfLastInteraction]];
    NSLog(@"userInfoString key for notification dict %@", userInfoString);
    buddy.buddyID = userInfoString;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:buddy.buddyID forKey:@"ID"];
    notification.userInfo = userInfo;
    notification.applicationIconBadgeNumber += 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    UILocalNotification *notification2 = [[UILocalNotification alloc] init];
    notification2.fireDate = [self addNumberOfDays:28 toDate:buddy.dateOfLastInteraction];
    notification2.repeatInterval = NSMonthCalendarUnit;
    notification2.timeZone = [NSTimeZone defaultTimeZone];
    notification2.alertBody = [self.alertMessages objectAtIndex:randomMessagePosition];
    notification2.alertAction = NSLocalizedString(@"Take me to their beautiful face", nil);
    notification2.soundName = UILocalNotificationDefaultSoundName;
    notification2.userInfo = userInfo;
    notification2.applicationIconBadgeNumber += 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification2];
}

- (void)cancelNotificationsForBuddy:(HISBuddy *)buddy
{
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *userInfoString = [buddy.name stringByAppendingString:[NSString stringWithFormat:@"%@", buddy.dateOfLastInteraction]];
        if ([userInfoString isEqualToString:[userInfo objectForKey:@"ID"]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (NSMutableArray *)alertMessages
{
    if (!_alertMessages) {
        _alertMessages = [[NSMutableArray alloc] init];
    }
    NSString *message1 = [NSString stringWithFormat:@"It's been a while since you last connected with %@.", self.buddyName];
    NSString *message2 = [NSString stringWithFormat:@"%@ misses you. Why don't you give 'em a call?", self.buddyName];
    NSString *message3 = [NSString stringWithFormat:@"%@ is drifting towards your outer circle.", self.buddyName];
    NSString *message4 = [NSString stringWithFormat:@"All the fun times %@ is having without me. Let's text!", self.buddyName];
    NSString *message5 = [NSString stringWithFormat:@"If only there was something to remind me to call %@, our closeness would be epic.", self.buddyName];
    
    [_alertMessages addObject:message1];
    [_alertMessages addObject:message2];
    [_alertMessages addObject:message3];
    [_alertMessages addObject:message4];
    [_alertMessages addObject:message5];
                          
    return _alertMessages;
}

- (NSDate *)addNumberOfDays:(NSInteger)days toDate:(NSDate *)date
{
    return [date dateByAddingTimeInterval:10];
    
//    60*60*24*days
}

@end
