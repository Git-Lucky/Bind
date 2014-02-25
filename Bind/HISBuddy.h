//
//  HISFriend.h
//  Bind
//
//  Created by Tim Hise on 2/1/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HISBuddy : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *pic;
@property (strong, nonatomic) NSString *imagePath;
@property (nonatomic) BOOL hasPlaceholderImage;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *twitter;
@property (nonatomic) BOOL innerCircle;
@property (nonatomic) BOOL getsReminders;
@property (nonatomic) CGFloat affinity;
@property (strong, nonatomic) NSDate *dateOfBirth;
@property (strong, nonatomic) NSString *dateOfBirthString;
@property (strong, nonatomic) NSDate *dateOfLastCalculation;
@property (nonatomic) BOOL hasAnimated;
@property (nonatomic) BOOL hasChanged;
@property (strong, nonatomic) NSString *buddyID;
@property (nonatomic) CGFloat previousAffinity;


@end
