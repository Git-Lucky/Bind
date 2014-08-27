//
//  HISWideCellVC.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISBuddyListViewController.h"
#import "HISCollectionViewDataSource.h"
#import "HISBuddyDetailsViewController.h"
#import "HISEditBuddyViewController.h"
#import "HISGetStartedViewController.h"
#import "HISLocalNotificationController.h"
#import "HISAddFriendFooter.h"
#import "HISSearchHeader.h"
#import "HISNewBuddyViewController.h"
#import "HISTransitioningController.h"
#import "HISTransitionAnimator.h"
#import "HISCVCell.h"


@interface HISBuddyListViewController () <UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (strong, nonatomic) HISTransitionAnimator *animator;

@end


@implementation HISBuddyListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"startupTutorial"]) {
//        createBuddy.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:createBuddy animated:NO completion:^{
//            createBuddy.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        }];
//    };
//
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"startupTutorial"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = [HISCollectionViewDataSource sharedDataSource];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    LXReorderableCollectionViewFlowLayout *collectionViewLayout = (LXReorderableCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(35, 2, 20, 2);
    
    [self.collectionView registerClass:[HISAddFriendFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"addFriendFooter"];
    
    [self.collectionView registerClass:[HISSearchHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchbar"];
    
//    self.transitioningController = [[HISTransitioningController alloc] initWithAnimator:[HISTransitionAnimator new]];
    self.animator = [HISTransitionAnimator new];
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
    
    [self processAndDisplayBackgroundImage:backgroundImage];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
}

- (void)processAndDisplayBackgroundImage:(NSString *)imageName
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCollectionViewDataSource *dataSource = [HISCollectionViewDataSource sharedDataSource];
    if (indexPath.row == dataSource.buddies.count) {
        [self performSegueWithIdentifier:@"toCreate" sender:self];
    } else {
        self.animator.indexPathOfSelectedCell = indexPath;
        HISBuddyDetailsViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsVC"];
        HISBuddy *buddy = [dataSource.buddies objectAtIndex:indexPath.row];
        destVC.buddy = buddy;
        destVC.indexPath = indexPath;
        
        [self.navigationController pushViewController:destVC animated:YES];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    switch (operation) {
        case UINavigationControllerOperationPush:   self.animator.isPresenting = YES;   break;
        case UINavigationControllerOperationPop:    self.animator.isPresenting = NO;    break;
        default:                                                                        break;
    }
    
    return self.animator;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDetails"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        HISCollectionViewDataSource *dataSource = [HISCollectionViewDataSource sharedDataSource];
        
        HISBuddyDetailsViewController *destVC = segue.destinationViewController;
        HISBuddy *buddy = [dataSource.buddies objectAtIndex:indexPath.row];
        
        destVC.buddy = buddy;
        destVC.indexPath = indexPath;
    }
}
- (IBAction)removedFriend:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[HISEditBuddyViewController class]]) {
        HISEditBuddyViewController *removeBuddyVC = (HISEditBuddyViewController *)segue.sourceViewController;
        HISBuddy *oldBuddy = removeBuddyVC.buddy;
        if (oldBuddy) {
            
            [[HISCollectionViewDataSource sharedDataSource].buddies removeObject:oldBuddy];
            
            [self.localNotificationController cancelNotificationsForBuddy:oldBuddy];
            
            [self.collectionView reloadData];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}

- (IBAction)addedFriend:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[HISNewBuddyViewController class]]) {
        HISNewBuddyViewController *createBuddy = (HISNewBuddyViewController *)segue.sourceViewController;
        HISBuddy *newBuddy = createBuddy.buddyToAdd;
        
        if (newBuddy) {
            [[HISCollectionViewDataSource sharedDataSource].buddies addObject:newBuddy];
            [self.collectionView reloadData];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}

@end
