//
//  Animator.h
//  Bind
//
//  Created by Tim Hise on 3/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animator : NSObject

- (void)fadeIn:(UIView *)view withDuration:(double)duration;

- (void)fadeOut:(UIView *)view withDuration:(double)duration;

- (void)repeatFade:(UIView *)view withDuration:(double)duration;

- (void)shrink:(UIView *)view withDuration:(double)duration;

- (void)grow:(UIView *)view withDuration:(double)duration;

- (void)changeBackground:(UIImageView *)view toImage:(UIImage *)image withDuration:(double)duration;

- (void)sleep:(double)timeInSeconds;

@end
