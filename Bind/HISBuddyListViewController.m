//
//  HISWideCellVC.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISBuddyListViewController.h"
#import "HISCVCellWide.h"
#import "HISCollectionViewDataSource.h"
#import "HISBuddyDetailsViewController.h"
#import "HISBuddy.h"
#import "HISEditBuddyViewController.h"
#import "HISGetStartedViewController.h"


@interface HISBuddyListViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HISCollectionViewDataSource *dataSource;

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
    self.collectionView.dataSource = self.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.dataSource.buddies.count == 0) {
//        HISGetStartedViewController *getStartedViewController = [[HISGetStartedViewController alloc] init];
//        getStartedViewController.view.backgroundColor = [UIColor clearColor]; // can be with 'alpha'
//        [self presentViewController:getStartedViewController animated:YES completion:nil];
    }
}

- (HISCollectionViewDataSource *)dataSource
{
    if (!_dataSource){
        _dataSource = [[HISCollectionViewDataSource alloc] init];
    }
    return _dataSource;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDetails"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        
        HISBuddyDetailsViewController *destVC = segue.destinationViewController;
        HISBuddy *buddy = [self.dataSource.buddies objectAtIndex:indexPath.row];
        
        destVC.buddy = buddy;
        destVC.dataSource = self.dataSource;
    }
}
- (IBAction)removedFriend:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[HISEditBuddyViewController class]]) {
        HISEditBuddyViewController *removeBuddyVC = (HISEditBuddyViewController *)segue.sourceViewController;
        HISBuddy *oldBuddy = removeBuddyVC.buddy;
        if (oldBuddy) {
            
            [self.dataSource.buddies removeObject:oldBuddy];
            [self.collectionView reloadData];
            
            [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
        }
    }
}

- (IBAction)addedFriend:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[HISCreateBuddyViewController class]]) {
        HISCreateBuddyViewController *createBuddy = (HISCreateBuddyViewController *)segue.sourceViewController;
        HISBuddy *newBuddy = createBuddy.buddyToAdd;
        
        if (newBuddy) {
            [self.dataSource.buddies addObject:newBuddy];
            [self.collectionView reloadData];
            
            [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
        }
    }
}

//NSData *data = [NSData dataWithContentsOfFile:[[self documentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.student.name]]];
//if (data) {
//    self.student.image = [UIImage imageWithData:data];
//    [self.imageButton setBackgroundImage:self.student.image forState:UIControlStateNormal];
//}
//if (self.student.imagePath) {
//    [self.imageButton setTitle:@"" forState:UIControlStateNormal];
//}
//if (self.imageButton.imageView.image) {
//    self.imageButton.adjustsImageWhenHighlighted = NO;
//    //        [self.imageButton setUserInteractionEnabled:NO];
//}

@end
