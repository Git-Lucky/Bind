//
//  HISWideCellVC.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HISBuddy.h"

@interface HISBuddyListViewController : UIViewController <UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
