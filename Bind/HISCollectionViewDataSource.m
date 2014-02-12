//
//  HISCollectionViewDataSource.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCollectionViewDataSource.h"
#import "HISCVCellWide.h"
#import "HISCVCell.h"

@interface HISCollectionViewDataSource ()

@end

@implementation HISCollectionViewDataSource

+ (HISCollectionViewDataSource *)sharedDataSource
{
    static dispatch_once_t pred;
    static HISCollectionViewDataSource *sharedDataSource = nil;
    
    dispatch_once(&pred, ^{
        sharedDataSource = [[HISCollectionViewDataSource alloc] init];
    });
    
    return sharedDataSource;
}

#pragma mark - Collection View

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    HISBuddy *buddy = self.buddies[indexPath.row];
    
    NSString *firstName;
    firstName = [[buddy.name componentsSeparatedByString:@" "] firstObject];
    cell.name.text = firstName;
    
    
    if (buddy.imagePath) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:buddy.imagePath];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
    
    [cell.progressViewPie setProgress:buddy.affinity animated:YES];
    
//    cell.progressViewPie.backgroundRingWidth = 1;
    
    if (!buddy.hasAnimated) {
        [cell.progressViewPie setAnimationDuration: 1 ];
        buddy.hasAnimated = YES;
    } else if (buddy.hasChanged) {
        [cell.progressViewPie setAnimationDuration: 1 ];
        buddy.hasChanged = NO;
    } else {
        [cell.progressViewPie setAnimationDuration: 0 ];
    }
    
    [HISCollectionViewDataSource makeRoundView:cell.imageView];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.buddies.count;
}

+ (void)makeRoundView:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.layer.masksToBounds = YES;
//    view.layer.borderColor = [UIColor colorWithRed:0.940 green:0.964 blue:0.975 alpha:1.000].CGColor;
//    view.layer.borderWidth = 0;
}

- (NSMutableArray *)buddies
{
    if (!_buddies && [HISCollectionViewDataSource archivedFriendsPath]) {
        _buddies = [self load];
    }
    if (!_buddies) {
        _buddies = [[NSMutableArray alloc] init];
    }
    return _buddies;
}

#pragma mark - Archiver

- (BOOL)saveRootObject
{
    return [NSKeyedArchiver archiveRootObject:self.buddies toFile:[HISCollectionViewDataSource archivedFriendsPath]];
}

- (NSMutableArray *)load
{
     NSMutableArray *unarchivedArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[HISCollectionViewDataSource archivedFriendsPath]];
    
    //loop through all objects and update affinity value
    NSDate *now = [NSDate date];
    for (HISBuddy *buddy in unarchivedArray) {
        if (buddy.dateOfLastInteraction) {
            NSLog(@"Affinity before %f", buddy.affinity);
            NSDate *lastInteraction = buddy.dateOfLastInteraction;
            NSInteger daysBetween = [HISCollectionViewDataSource daysBetween:lastInteraction and:now];
            float percentLost = (CGFloat)daysBetween/100.f;
            buddy.affinity -= percentLost;
            if (buddy.affinity < 0) {
                buddy.affinity = 0.01;
            }
            NSLog(@"Affinity After %f", buddy.affinity);
        }
    }
    return unarchivedArray;
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

+ (NSInteger)daysBetween:(NSDate *)date1 and:(NSDate *)date2
{
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date1 toDate:date2 options:0];
    return [components day];
}


@end
