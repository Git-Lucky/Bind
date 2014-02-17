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
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *twitter;
@property (nonatomic) CGFloat affinity;
@property (strong, nonatomic) NSDate *dateOfLastInteraction;
@property (nonatomic) BOOL hasAnimated;
@property (nonatomic) BOOL hasChanged;
@property (strong, nonatomic) NSString *buddyID;
@property (nonatomic) CGFloat previousAffinity;


@end
