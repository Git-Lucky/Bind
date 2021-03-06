//
//  HISViewController.m
//  Bind
//
//  Created by Tim Hise on 1/31/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HISCVCell.h"
#import "HISCollectionViewDataSource.h"

@interface HISViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *secondaryCollectionViewTop;
@property (weak, nonatomic) IBOutlet UICollectionView *primaryCollectionView;
@property (strong, nonatomic) NSMutableArray *primaryCircleOfFriends;
@property (strong, nonatomic) NSMutableArray *secondaryCircleOfFriends;


@end

@implementation HISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.primaryCollectionView.delegate = self;
    self.primaryCollectionView.dataSource = [HISCollectionViewDataSource sharedDataSource];
	self.secondaryCollectionViewTop.delegate = self;
    self.secondaryCollectionViewTop.dataSource= self;
    
//    [self.primaryCollectionView reloadData];
    
//    [self makeRoundView:self.primaryCollectionView];
    [self makeRoundView:self.secondaryCollectionViewTop];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Should Have %ld Views", (long)[_primaryCollectionView numberOfItemsInSection:0]);
    [self.primaryCollectionView reloadData];
}

- (void)giveShadowToViewController:(UIView *)View
{
    [View.layer setShadowOpacity:0.4];
    [View.layer setShadowOffset:CGSizeMake(-10, -20)];
    [View.layer setShadowColor:[UIColor blackColor].CGColor];
}

#pragma mark - Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.primaryCollectionView) {
        return self.primaryCircleOfFriends.count;
    } else if (collectionView == self.secondaryCollectionViewTop) {
        return self.secondaryCircleOfFriends.count;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HISCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self makeRoundView:cell];
    
    return cell;
}



- (void)makeRoundView:(UIView *)view
{
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.clipsToBounds = YES;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2;
}

@end
