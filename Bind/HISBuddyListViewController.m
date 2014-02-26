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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
    
    [self processAndDisplayBackgroundImage:backgroundImage];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDetails"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        HISBuddyDetailsViewController *destVC = segue.destinationViewController;
        HISBuddy *buddy = [[HISCollectionViewDataSource sharedDataSource].buddies objectAtIndex:indexPath.row];
        
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
            NSLog(@"newbuddy %@", newBuddy.dateOfBirth);
            [[HISCollectionViewDataSource sharedDataSource].buddies addObject:newBuddy];
            [self.collectionView reloadData];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}

@end
