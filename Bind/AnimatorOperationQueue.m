//
//  SharedOperationQueue.m
//  Bind
//
//  Created by Tim Hise on 3/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "AnimatorOperationQueue.h"

@implementation AnimatorOperationQueue

+ (AnimatorOperationQueue *)sharedOperationQueue
{
    static dispatch_once_t pred;
    static AnimatorOperationQueue *sharedOperationQueue = nil;
    
    dispatch_once(&pred, ^{
        sharedOperationQueue = [[AnimatorOperationQueue alloc] init];
    });
    
    return sharedOperationQueue;
}

@end
