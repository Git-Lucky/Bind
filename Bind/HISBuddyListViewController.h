//
//  HISWideCellVC.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HISCreateBuddyViewController.h"
#import "HISBuddy.h"

@interface HISBuddyListViewController : UIViewController <UICollectionViewDelegate>

@property (strong, nonatomic) HISCreateBuddyViewController *createBuddyViewController;

@end
