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
#import "HISCreateBuddyViewController.h"


@interface HISBuddyListViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (weak, nonatomic) IBOutlet UIView *plusBorder;

@end

@implementation HISBuddyListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = [HISCollectionViewDataSource sharedDataSource];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    LXReorderableCollectionViewFlowLayout *collectionViewLayout = (LXReorderableCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(25, 0, 0, 0);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
    
    [self processAndDisplayBackgroundImage:backgroundImage];
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
    
    self.plusBorder.layer.borderWidth = 1;
    self.plusBorder.layer.borderColor = [[UIColor clearColor]CGColor];
    self.plusBorder.layer.backgroundColor = [[UIColor clearColor]CGColor];
    self.plusBorder.layer.cornerRadius = self.plusBorder.frame.size.height / 2;
    
    [UIView animateWithDuration:1.f animations:^{
        self.plusBorder.layer.borderColor = [[UIColor whiteColor]CGColor];
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCollectionViewDataSource *dataSource = [HISCollectionViewDataSource sharedDataSource];
    
    if (indexPath.row == dataSource.buddies.count) {
        [self performSegueWithIdentifier:@"toCreate" sender:self];
    } else {
        [self performSegueWithIdentifier:@"toDetails" sender:self];
    }
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

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
    if ([segue.sourceViewController isKindOfClass:[HISCreateBuddyViewController class]]) {
        HISCreateBuddyViewController *createBuddy = (HISCreateBuddyViewController *)segue.sourceViewController;
        HISBuddy *newBuddy = createBuddy.buddyToAdd;
        
        if (newBuddy) {
            [[HISCollectionViewDataSource sharedDataSource].buddies addObject:newBuddy];
            [self.collectionView reloadData];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}

@end
