//
//  HISCollectionViewDataSource.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXReorderableCollectionViewFlowLayout.h"

@interface HISCollectionViewDataSource : NSObject <UICollectionViewDataSource, LXReorderableCollectionViewDataSource, UICollectionViewDelegate>


@property (strong, nonatomic) NSMutableArray *buddies;
@property (strong, nonatomic) UIImage *navBarImage;
@property (strong, nonatomic) NSIndexPath *indexPath;

+ (HISCollectionViewDataSource *)sharedDataSource;

+ (NSString *)archivedFriendsPath;
+ (NSString *)documentsDirectoryPath;
+ (void)makeRoundView:(UIView *)view;

- (NSMutableArray *)load;
- (BOOL)saveRootObject;
- (NSArray *)indexPathsOfBuddies;

@end
