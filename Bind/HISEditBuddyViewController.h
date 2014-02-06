//
//  HISEditBuddyViewController.h
//  Bind
//
//  Created by Tim Hise on 2/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HISBuddy.h"

@interface HISEditBuddyViewController : UIViewController

@property (strong, nonatomic) HISBuddy *buddy;
@property (strong, nonatomic) HISBuddy *editedBuddy;

@end
