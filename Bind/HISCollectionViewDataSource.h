//
//  HISCollectionViewDataSource.h
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HISCollectionViewDataSource : NSObject <UICollectionViewDataSource>


@property (strong, nonatomic) NSMutableArray *buddies;
@property (strong, nonatomic) UIImage *navBarImage;

+ (HISCollectionViewDataSource *)sharedDataSource;

+ (NSString *)archivedFriendsPath;
+ (NSString *)documentsDirectoryPath;
+ (void)makeRoundView:(UIView *)view;

- (NSMutableArray *)load;
- (BOOL)saveRootObject;
- (NSArray *)indexPathsOfBuddies;

@end
