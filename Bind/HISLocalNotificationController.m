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
    //notify every week for inner circle
    if (buddy.innerCircle) {
        self.buddyName = buddy.name;
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [self addNumberOfDays:7 toDate:[NSDate date]];
        notification.repeatInterval = NSWeekCalendarUnit;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        
        int randomMessagePosition = arc4random() % [self.alertMessages count];
        notification.alertBody = [self.alertMessages objectAtIndex:randomMessagePosition];
        notification.alertAction = NSLocalizedString(@"Take me to their beautiful face", nil);
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        NSString *userInfoString = [buddy.name stringByAppendingString:[NSString stringWithFormat:@"%@", buddy.dateOfLastCalculation]];
        buddy.buddyID = userInfoString;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:buddy.buddyID forKey:@"ID"];
        notification.userInfo = userInfo;
        notification.applicationIconBadgeNumber += 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        NSLog(@"innerCircle Notification Scheduled for %@", buddy.name);
    }
    
    if (buddy.dateOfBirth) {
        NSDate *now = [NSDate date];
        NSTimeInterval month = 60 * 60 * 24 * 30;
        NSDate *nextMonth = [NSDate dateWithTimeInterval:month sinceDate:now];
        
        if (([now compare:buddy.dateOfBirth] != NSOrderedDescending) && ([buddy.dateOfBirth compare:nextMonth] != NSOrderedDescending)) {
            UILocalNotification *birthdayNotification = [[UILocalNotification alloc] init];
            birthdayNotification.fireDate = [self setTimeOnBirthdayForBuddy:buddy];
            birthdayNotification.timeZone = [NSTimeZone defaultTimeZone];

            birthdayNotification.alertBody = [NSString stringWithFormat:@"Be sure to wish %@ a Happy Birthday!", buddy.name];
            birthdayNotification.alertAction = NSLocalizedString(@"Take me to their beautiful face", nil);
            birthdayNotification.soundName = UILocalNotificationDefaultSoundName;
            
            NSString *userInfoString = [buddy.name stringByAppendingString:[NSString stringWithFormat:@"%@", buddy.dateOfLastCalculation]];
            buddy.buddyID = userInfoString;
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:buddy.buddyID forKey:@"ID"];
            birthdayNotification.userInfo = userInfo;
            birthdayNotification.applicationIconBadgeNumber += 1;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:birthdayNotification];
            
            NSLog(@"Birthday notification scheduled for %@", buddy.name);
        }
    }
}

- (void)cancelNotificationsForBuddy:(HISBuddy *)buddy
{
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *userInfoString = [buddy.name stringByAppendingString:[NSString stringWithFormat:@"%@", buddy.dateOfLastCalculation]];
        if ([userInfoString isEqualToString:[userInfo objectForKey:@"ID"]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            NSLog(@"Notifs canceled for %@", buddy.name);
        }
    }
}

- (NSMutableArray *)alertMessages
{
    if (!_alertMessages) {
        _alertMessages = [[NSMutableArray alloc] init];
    }
    NSString *message1 = [NSString stringWithFormat:@"It's time to call %@.", self.buddyName];
    NSString *message2 = [NSString stringWithFormat:@"%@ misses you. Why don't you give 'em a call?", self.buddyName];
    NSString *message3 = [NSString stringWithFormat:@"%@ is drifting towards your outer circle.", self.buddyName];
    NSString *message4 = [NSString stringWithFormat:@"All the fun times %@ is having without me. Let's text!", self.buddyName];
    NSString *message5 = [NSString stringWithFormat:@"Another week, another chance to call %@", self.buddyName];
    
    [_alertMessages addObject:message1];
    [_alertMessages addObject:message2];
    [_alertMessages addObject:message3];
    [_alertMessages addObject:message4];
    [_alertMessages addObject:message5];
                          
    return _alertMessages;
}

- (NSDate *)addNumberOfDays:(NSInteger)days toDate:(NSDate *)date
{
    return [date dateByAddingTimeInterval:60*60*24*days];
    
//    60*60*24*days
}

- (NSDate *)setTimeOnBirthdayForBuddy:(HISBuddy *)buddy
{
    NSDate *bdayWithTime = buddy.dateOfBirth;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:bdayWithTime];
    [components setHour:10];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *newDate = [calendar dateFromComponents:components];
    buddy.dateOfBirth = newDate;
    
    return newDate;
}

@end
