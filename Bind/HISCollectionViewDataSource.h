//
//  HISCollectionViewDataSource.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13ProgressViewSegmentedBar.h"

@interface HISCollectionViewDataSource : NSObject <UICollectionViewDataSource>


@property (strong, nonatomic) NSMutableArray *buddies;

+ (NSString *)archivedFriendsPath;
+ (NSString *)documentsDirectoryPath;
+ (NSMutableArray *)load;
+ (BOOL)saveRootObject:(id)rootObject;
+ (void)makeRoundView:(UIView *)view;

@end
