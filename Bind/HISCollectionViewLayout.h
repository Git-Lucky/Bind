//
//  HISCollectionViewLayout.h
//  Bind
//
//  Created by Tim Hise on 2/14/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HISCollectionViewLayout : UICollectionViewLayout

-(void)detachItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion;

@end
