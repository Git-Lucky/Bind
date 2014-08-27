//
//  HISTransitionAnimator.h
//  Bind
//
//  Created by Tim Hise on 8/17/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13ProgressViewPie.h"

@interface HISTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL isPresenting;
@property (nonatomic) NSIndexPath *indexPathOfSelectedCell;

@end
