//
//  HISCVCell.h
//  Bind
//
//  Created by Tim Hise on 2/1/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13ProgressViewPie.h"

@interface HISCVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIView *greyBackView;
@property (weak, nonatomic) IBOutlet UIView *innerGreyBorder;

@end
