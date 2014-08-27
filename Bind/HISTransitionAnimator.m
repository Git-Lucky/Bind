//
//  HISTransitionAnimator.m
//  Bind
//
//  Created by Tim Hise on 8/17/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISTransitionAnimator.h"
#import "HISBuddyListViewController.h"
#import "HISBuddyDetailsViewController.h"
#import "HISCVCell.h"
#import "HISCollectionViewDataSource.h"

#define ACTING_ZERO 0.001f

@interface HISTransitionAnimator ()

@property (nonatomic) UIImageView *detailAvatarImageView;
@property (nonatomic) M13ProgressViewPie *detailPieProgressView;
@property (strong, nonatomic) HISCVCell *cell;

@end

@implementation HISTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    
    UIImageView *transitionAvatarImageView;
    M13ProgressViewPie *transitionPieProgressView;
    
    CGRect cellAvatarImageFrame;
    CGRect cellPieImageFrame;
    CGRect detailAvatarImageFrame;
    CGRect detailPieImageFrame;
    
    if (self.isPresenting) {
        UICollectionView *collectionView = [(HISBuddyListViewController *)fromViewController collectionView];
        self.cell = (HISCVCell *)[collectionView cellForItemAtIndexPath:self.indexPathOfSelectedCell];
        self.cell.hidden = YES;
        
        HISBuddyDetailsViewController *detailsViewController = (HISBuddyDetailsViewController *)toViewController;
        self.detailAvatarImageView = detailsViewController.buddyImageView;
        self.detailPieProgressView = detailsViewController.pieImageView;
        
        toViewController.view.alpha = 0.0f;
        cellAvatarImageFrame = [fromViewController.view convertRect:self.cell.imageView.frame fromView:self.cell.imageView.superview];
        cellPieImageFrame = [fromViewController.view convertRect:self.cell.progressViewPie.frame fromView:self.cell.progressViewPie.superview];
        detailAvatarImageFrame = [toViewController.view convertRect:self.detailAvatarImageView.frame fromView:self.detailAvatarImageView.superview];
        detailPieImageFrame = [toViewController.view convertRect:self.detailPieProgressView.frame fromView:self.detailPieProgressView.superview];
        
        transitionAvatarImageView = [[UIImageView alloc] initWithFrame:cellAvatarImageFrame];
        transitionAvatarImageView.image = self.cell.imageView.image;
        transitionPieProgressView = [[M13ProgressViewPie alloc] initWithFrame:cellPieImageFrame];
        [transitionPieProgressView setProgress:self.cell.progressViewPie.progress animated:NO];
        
        self.detailAvatarImageView.image = transitionAvatarImageView.image;
        [self.detailPieProgressView setProgress:transitionPieProgressView.progress animated:NO];
    } else {
        fromViewController.view.alpha = 1.0f;
        cellAvatarImageFrame = [toViewController.view convertRect:self.cell.imageView.frame fromView:self.cell.imageView.superview];
        cellPieImageFrame = [toViewController.view convertRect:self.cell.progressViewPie.frame fromView:self.cell.progressViewPie.superview];
        detailAvatarImageFrame = [fromViewController.view convertRect:self.detailAvatarImageView.frame fromView:self.detailAvatarImageView.superview];
        detailPieImageFrame = [fromViewController.view convertRect:self.detailPieProgressView.frame fromView:self.detailPieProgressView.superview];
        
        transitionAvatarImageView = [[UIImageView alloc] initWithFrame:detailAvatarImageFrame];
        transitionAvatarImageView.image = self.cell.imageView.image;
        transitionPieProgressView = [[M13ProgressViewPie alloc] initWithFrame:detailPieImageFrame];
        [transitionPieProgressView setProgress:self.detailPieProgressView.progress animated:NO];
        [containerView bringSubviewToFront:fromViewController.view];

        [[HISCollectionViewDataSource sharedDataSource] setIndexPath:self.indexPathOfSelectedCell];
    }
    
    self.detailPieProgressView.hidden = YES;
    self.detailAvatarImageView.hidden = YES;
    
    transitionAvatarImageView.layer.cornerRadius = transitionAvatarImageView.frame.size.height / 2;
    transitionAvatarImageView.layer.masksToBounds = YES;
    [transitionAvatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [containerView addSubview:transitionPieProgressView];
    [containerView addSubview:transitionAvatarImageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat avatarScaleFactorX = detailAvatarImageFrame.size.width / cellAvatarImageFrame.size.width;
        CGFloat avatarScaleFactorY = detailAvatarImageFrame.size.height / cellAvatarImageFrame.size.height;
        if (self.isPresenting) {
            toViewController.view.alpha = 1.0f;
            transitionPieProgressView.transform = CGAffineTransformMakeScale(avatarScaleFactorX, avatarScaleFactorY);
            transitionAvatarImageView.transform = CGAffineTransformMakeScale(avatarScaleFactorX, avatarScaleFactorY);
            transitionAvatarImageView.center = CGPointMake(detailAvatarImageFrame.size.width / 2 + detailAvatarImageFrame.origin.x,
                                                        detailAvatarImageFrame.size.height / 2 + detailAvatarImageFrame.origin.y);
            transitionPieProgressView.center = CGPointMake(detailPieImageFrame.size.width / 2 + detailPieImageFrame.origin.x,
                                                        detailPieImageFrame.size.height / 2 + detailPieImageFrame.origin.y);
        } else {
            fromViewController.view.alpha = 0.0f;
            transitionPieProgressView.transform = CGAffineTransformMakeScale(1/avatarScaleFactorX, 1/avatarScaleFactorY);
            transitionAvatarImageView.transform = CGAffineTransformMakeScale(1/avatarScaleFactorX, 1/avatarScaleFactorY);
            transitionAvatarImageView.center = CGPointMake(cellAvatarImageFrame.size.width / 2 + cellAvatarImageFrame.origin.x,
                                                        cellAvatarImageFrame.size.height / 2 + cellAvatarImageFrame.origin.y);
            transitionPieProgressView.center = CGPointMake(cellPieImageFrame.size.width / 2 + cellPieImageFrame.origin.x,
                                                        cellPieImageFrame.size.height / 2 + cellPieImageFrame.origin.y);
        }
        
    } completion:^(BOOL finished) {
        if (!self.isPresenting) {
            UICollectionView *collectionView = [(HISBuddyListViewController *)toViewController collectionView];
            self.cell = (HISCVCell *)[collectionView cellForItemAtIndexPath:self.indexPathOfSelectedCell];
            self.cell.hidden = NO;
            [[HISCollectionViewDataSource sharedDataSource] setIndexPath:nil];
            [collectionView reloadItemsAtIndexPaths:@[self.indexPathOfSelectedCell]];
        }
        
        self.detailPieProgressView.hidden = NO;
        self.detailAvatarImageView.hidden = NO;
        
        [transitionPieProgressView removeFromSuperview];
        [transitionAvatarImageView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
