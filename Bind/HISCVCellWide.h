//
//  HISCVCellWide.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HISBuddy.h"
#import "M13ProgressViewSegmentedBar.h"

@interface HISCVCellWide : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIProgressView *affinityLevel;
@property (weak, nonatomic) IBOutlet M13ProgressViewSegmentedBar *segmentedBar;
@property (weak, nonatomic) HISBuddy *buddy;
@property (weak, nonatomic) IBOutlet UIImageView *dividerImageView;

@end
