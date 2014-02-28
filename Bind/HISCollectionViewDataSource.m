//
//  HISCollectionViewDataSource.m
//  friends 4 life
//  life long friends
//  orange
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCollectionViewDataSource.h"
#import "HISCVCell.h"
#import "HISBuddy.h"
#import "HISAddFriendFooter.h"

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
    
    if (indexPath.row < self.buddies.count) {
        HISBuddy *buddy = self.buddies[indexPath.row];
        
        NSString *firstName;
        firstName = [[buddy.name componentsSeparatedByString:@" "] firstObject];
        cell.name.text = firstName;
        
        if (buddy.imagePath) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:buddy.imagePath];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"Placeholder_female_superhero_c.png"];
        }
        
        if (!buddy.hasAnimated) {
            [cell.progressViewPie setAnimationDuration:2];
            buddy.hasAnimated = YES;
        } else if (buddy.hasChanged) {
            [cell.progressViewPie setAnimationDuration:2];
            buddy.hasChanged = NO;
        } else {
            [cell.progressViewPie setAnimationDuration:.01];
        }
            [cell.progressViewPie setProgress:buddy.previousAffinity animated:NO];
            [cell.progressViewPie setProgress:buddy.affinity animated:YES];
            buddy.previousAffinity = buddy.affinity;
        
        [HISCollectionViewDataSource makeRoundView:cell.imageView];
        cell.backgroundColor = [UIColor clearColor];
        cell.progressViewPie.hidden = NO;
    } else {
        cell.name.text = @"Add Friend";
        cell.imageView.image = [UIImage imageNamed:@"plus_white.png"];
        [HISCollectionViewDataSource makeRoundView:cell.imageView];
        cell.progressViewPie.hidden = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.buddies.count + 1;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.row < self.buddies.count && fromIndexPath.row < self.buddies.count) {
        id object = [self.buddies objectAtIndex:fromIndexPath.item];
        [self.buddies removeObjectAtIndex:fromIndexPath.item];
        [self.buddies insertObject:object atIndex:toIndexPath.item];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    
    if (kind == UICollectionElementKindSectionFooter) {
        
        HISAddFriendFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"addFriendFooter" forIndexPath:indexPath];
        
        footer.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        footer.button.imageView.backgroundColor = [UIColor redColor];
        footer.name = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 60, 30)];
        footer.name.backgroundColor = [UIColor purpleColor];
        
        reusableView = footer;
    }
    
    
    return reusableView;
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
        if (buddy.dateOfLastCalculation) {

//            NSDateComponents *components = [[NSDateComponents alloc]init];
//            [components setDay:1];
//            [components setMonth:2];
//            [components setYear:2014];
//            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDate *date = [cal dateFromComponents:components];
//            buddy.dateOfLastInteraction = date;
            
            NSDate *lastInteraction = buddy.dateOfLastCalculation;
            NSInteger daysBetween = [HISCollectionViewDataSource daysBetween:lastInteraction and:now];
            
            NSLog(@"Affinity before %.2f, date: %@", buddy.affinity, buddy.dateOfLastCalculation);
            NSLog(@"days between %ld", (long)daysBetween);
            if (daysBetween > 0) {
                float percentLost = (CGFloat)daysBetween/100.f;
                buddy.affinity -= percentLost;
                if (buddy.affinity < 0) {
                    buddy.affinity = 0.05;
                }
                buddy.dateOfLastCalculation = now;
                NSLog(@"Affinity After %.2f, date: %@", buddy.affinity, buddy.dateOfLastCalculation);
            }
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

- (NSArray *)indexPathsOfBuddies
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.buddies enumerateObjectsUsingBlock:^(id event, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            [indexPaths addObject:indexPath];
    }];
    return indexPaths;
}

@end
