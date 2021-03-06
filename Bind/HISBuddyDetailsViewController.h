//
//  HISDetailsVC.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HISBuddy.h"
#import "HISCollectionViewDataSource.h"
#import "M13ProgressViewPie.h"

@interface HISBuddyDetailsViewController : UIViewController

@property (strong, nonatomic) HISBuddy *buddy;
//@property (strong, nonatomic) HISCollectionViewDataSource *dataSource;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *buddyImageView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *pieImageView;

@end
