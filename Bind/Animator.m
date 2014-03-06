//
//  Animator.m
//  Bind
//
//  Created by Tim Hise on 3/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "Animator.h"
#import "AnimatorOperationQueue.h"

@implementation Animator

- (void)fadeIn:(UIView *)view withDuration:(double)duration
{
//    [view setAlpha:0.f];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:1.f];
        }];
    }];
}

- (void)fadeOut:(UIView *)view withDuration:(double)duration
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration animations:^{
            [view setAlpha:0.0f];
        }];
    }];
}

- (void)shrink:(UIView *)view withDuration:(double)duration
{
    CATransform3D transform3d = CATransform3DMakeScale(1.15, 1.15, 1.15);
    
    view.layer.transform = transform3d;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration animations:^{
            view.layer.transform = CATransform3DIdentity;
        }];
    }];
}

- (void)grow:(UIView *)view withDuration:(double)duration;
{
    CATransform3D transform3d = CATransform3DMakeScale(1.15, 1.15, 1.15);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration animations:^{
            view.layer.transform = transform3d;
        }];
    }];
}

- (void)sleep:(double)timeInSeconds
{
    usleep(timeInSeconds * 1000000);
}

@end
