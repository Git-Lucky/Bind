//
//  SharedOperationQueue.h
//  Bind
//
//  Created by Tim Hise on 3/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimatorOperationQueue : NSOperationQueue

+ (AnimatorOperationQueue *)sharedOperationQueue;

@end
