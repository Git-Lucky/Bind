//
//  HISLocalNotificationController.h
//  Bind
//
//  Created by Tim Hise on 2/6/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HISBuddy.h"


@interface HISLocalNotificationController : NSObject

- (void)scheduleNotificationsForBuddy:(HISBuddy *)buddy;
- (void)cancelNotificationsForBuddy:(HISBuddy *)buddy;

@end
