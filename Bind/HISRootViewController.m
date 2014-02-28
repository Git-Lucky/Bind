//
//  HISRootViewController.m
//  Bind
//
//  Created by Tim Hise on 2/13/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISRootViewController.h"
#import "HISCollectionViewDataSource.h"
#import "HISCVCell.h"
#import "HISBuddy.h"
#import "HISCollectionViewLayout.h"

@interface HISRootViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, assign) NSInteger count;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *buddies;

@end

@implementation HISRootViewController

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
    self.collectionView.dataSource = [HISCollectionViewDataSource sharedDataSource];//self;
    self.collectionView.collectionViewLayout = [[HISCollectionViewLayout alloc]init];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(userDidPressTrashButton:)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(userDidPressAddButton:)];
//    [self.collectionView reloadData];
}

- (NSMutableArray *)buddies
{
    if (!_buddies) {
        _buddies = [[NSMutableArray alloc] init];
        
        HISBuddy *buddy = [[HISBuddy alloc] init];
        buddy.name = @"George";
        HISBuddy *buddy2 = [[HISBuddy alloc] init];
        buddy2.name = @"Greg";
        
        [_buddies addObject:buddy];
        [_buddies addObject:buddy2];
    }
    return _buddies;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:YES];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
     [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)userDidPressAddButton:(id)sender {
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.count inSection:0]]];
        self.count++;
        self.navigationItem.rightBarButtonItem.enabled = self.count < 10;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } completion:nil];
}

-(void)userDidPressTrashButton:(id)sender {
    HISCollectionViewLayout *layout = (HISCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    // We have to prevent the user from modifying the contents until we've completed the deletion operation
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [layout detachItemAtIndexPath:[NSIndexPath indexPathForItem:self.count-1 inSection:0] completion:^{
        self.count--;
        self.navigationItem.leftBarButtonItem.enabled = self.count > 0;
        self.navigationItem.rightBarButtonItem.enabled = self.count < 10;
    }];
}

#pragma mark - CollectionView DataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    HISBuddy *buddy = self.buddies[indexPath.row];
    
    if (buddy.imagePath) {
        cell.imageView.image = buddy.pic;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder_female_superhero_c.png"];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.buddies.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
