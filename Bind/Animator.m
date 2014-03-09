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
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [view setAlpha:1.f];
        } completion:nil];
    }];
}

- (void)fadeOut:(UIView *)view withDuration:(double)duration
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [view setAlpha:0.2f];
        } completion:nil];
    }];
}

- (void)repeatFade:(UIView *)view withDuration:(double)duration
{
    [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction animations:^{
        [view setAlpha:0.1]; //first part of animation
//        [view setAlpha:1]; //second part of animation
    } completion:nil];
}

- (void)shrink:(UIView *)view withDuration:(double)duration
{
    CATransform3D transform3d = CATransform3DMakeScale(1.15, 1.15, 1.15);
    
    view.layer.transform = transform3d;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            view.layer.transform = CATransform3DIdentity;
        } completion:nil];
    }];
}

- (void)grow:(UIView *)view withDuration:(double)duration
{
    CATransform3D transform3d = CATransform3DMakeScale(1.15, 1.15, 1.15);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            view.layer.transform = transform3d;
        } completion:nil];
    }];
}

- (void)oscillateSize:(UIView *)view withDuration:(double)duration
{
    
}

- (void)sleep:(double)timeInSeconds
{
    usleep(timeInSeconds * 1000000);
}



@end
