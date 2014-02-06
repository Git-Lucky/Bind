//
//  HISCollectionViewDataSource.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCollectionViewDataSource.h"
#import "HISCVCellWide.h"

@implementation HISCollectionViewDataSource

#pragma mark - Collection View

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCVCellWide *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    HISBuddy *buddy = self.buddies[indexPath.row];
    
    cell.imageView.image = [UIImage imageWithContentsOfFile:buddy.imagePath];
    cell.name.text = buddy.name;
    
    [HISCollectionViewDataSource makeRoundView:cell.imageView];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.buddies.count;
}

+ (void)makeRoundView:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.clipsToBounds = YES;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2;
}

- (NSMutableArray *)buddies
{
    if (!_buddies) {
        _buddies = [HISCollectionViewDataSource load];
    }
    return _buddies;
}

#pragma mark - Archiver

+ (BOOL)saveRootObject:(id)rootObject
{
    return [NSKeyedArchiver archiveRootObject:rootObject toFile:[HISCollectionViewDataSource archivedFriendsPath]];
}

+ (NSMutableArray *)load
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[HISCollectionViewDataSource archivedFriendsPath]];
}

+ (NSString *)archivedFriendsPath
{
    return [[HISCollectionViewDataSource documentsDirectoryPath] stringByAppendingPathComponent:@"archive"];
}

+ (NSString *)documentsDirectoryPath
{
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsURL path];
}


@end
