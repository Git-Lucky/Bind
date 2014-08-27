//
//  HISTutorialTwoViewController.m
//  Bind
//
//  Created by Tim Hise on 3/5/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISTutorialTwoViewController.h"
#import "Animator.h"
#import "AnimatorOperationQueue.h"
#import "HISBuddyListViewController.h"

@interface HISTutorialTwoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *finalImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *againButton;
@property (weak, nonatomic) IBOutlet UIButton *gotItButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *first;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *second;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *third;
@property (nonatomic) int stage;
@property (strong, nonatomic) Animator *animator;
@property (nonatomic) BOOL nextButtonOn;
@property (strong, nonatomic) NSOperationQueue *operationQueue;


@end

@implementation HISTutorialTwoViewController

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
    
    self.operationQueue = [AnimatorOperationQueue sharedOperationQueue];
    
    self.animator = [[Animator alloc] init];
    
    [self.operationQueue setMaxConcurrentOperationCount:1];
    
    for (UILabel *sentence in self.first) {
        sentence.alpha = 0;
    }
    
    for (UILabel *sentence in self.second) {
        sentence.alpha = 0;
    }
    
    for (UILabel *sentence in self.third) {
        sentence.alpha = 0;
    }
    
    self.nextButton.alpha = 0;
    self.againButton.alpha = 0;
    self.gotItButton.alpha = 0;
    
    [self makeButton:self.nextButton];
    [self makeButton:self.againButton];
    [self makeButton:self.gotItButton];
    
    self.stage = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showIntro];
}

- (void)makeButton:(UIButton *)button
{
    button.layer.cornerRadius = button.frame.size.height / 2;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 2;
}

- (void)processAndDisplayBackgroundImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [image drawInRect:self.view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (IBAction)toContinue:(id)sender {
    if (self.stage == 1 && self.nextButtonOn) {
        [self continue1];
    } else if (self.stage == 2 && self.nextButtonOn) {
        [self continue2];
    }
}

- (IBAction)again:(id)sender {
    
    [self.againButton setEnabled:NO];
    
    self.nextButtonOn = NO;
    
    [self.operationQueue cancelAllOperations];
    
    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *label in self.third) {
            [self.animator fadeOut:label withDuration:.2];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator fadeOut:self.againButton withDuration:.2];
        [self.animator fadeOut:self.gotItButton withDuration:.2];
    }];
    
    [self showIntro];
}

- (IBAction)gotIt:(id)sender
{
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    HISBuddyListViewController *listViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listView"];
    [UIView animateWithDuration:.4 animations:^{
        self.finalImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [self presentViewController:navController animated:NO completion:^{
            [listViewController performSegueWithIdentifier:@"toCreate" sender:listViewController];
        }];
    }];
}

- (void)showIntro
{
    [self.operationQueue addOperationWithBlock:^{
        [self.animator changeBackground:self.backgroundImageView toImage:[UIImage imageNamed:@"createFriendBlurredTop"] withDuration:0];
    }];

    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *sentence in self.first) {
            [self.animator sleep:.8];
            [self.animator fadeIn:sentence withDuration:.4];
            [self.animator shrink:sentence withDuration:.4];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:1];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:.5];
        [self.animator fadeIn:self.nextButton withDuration:.4];
        [self.animator shrink:self.nextButton withDuration:.4];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        self.nextButtonOn = YES;
        while (self.nextButtonOn) {
            [self.animator grow:self.nextButton withDuration:1];
            [self.animator sleep:1];
            [self.animator shrink:self.nextButton withDuration:1];
            [self.animator sleep:1];
        }
    }];
}

- (void)continue1
{
    self.nextButtonOn = NO;
    
    [self.operationQueue cancelAllOperations];
    
    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *label in self.first) {
            [self.animator fadeOut:label withDuration:.2];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator changeBackground:self.backgroundImageView toImage:[UIImage imageNamed:@"createFriendBlurredTopBirthdayHighlight"] withDuration:5];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator fadeOut:self.nextButton withDuration:.2];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *sentence in self.second) {
            [self.animator sleep:1];
            [self.animator fadeIn:sentence withDuration:.4];
            [self.animator shrink:sentence withDuration:.4];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:1];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:1];
        self.stage ++;
        [self.animator fadeIn:self.nextButton withDuration:.4];
        [self.animator shrink:self.nextButton withDuration:.4];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        self.nextButtonOn = YES;
        while (self.nextButtonOn) {
            [self.animator grow:self.nextButton withDuration:1];
            [self.animator sleep:1];
            [self.animator shrink:self.nextButton withDuration:1];
            [self.animator sleep:1];
        }
    }];
}

- (void)continue2
{
    self.nextButtonOn = NO;
    
    [self.operationQueue cancelAllOperations];
    
    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *label in self.second) {
            [self.animator fadeOut:label withDuration:.2];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator fadeOut:self.nextButton withDuration:.2];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator changeBackground:self.backgroundImageView toImage:[UIImage imageNamed:@"createFriendBlurredTopWeeklyHighlight"] withDuration:5];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        for (UILabel *sentence in self.third) {
            [self.animator sleep:1];
            [self.animator fadeIn:sentence withDuration:.4];
            [self.animator shrink:sentence withDuration:.4];
        }
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:1];
    }];
    
    [self.againButton setEnabled:YES];
    
    [self.operationQueue addOperationWithBlock:^{
        [self.animator sleep:1];
        [self.animator fadeIn:self.gotItButton withDuration:.4];
        [self.animator shrink:self.gotItButton withDuration:.4];
        [self.animator fadeIn:self.againButton withDuration:.4];
    }];
    
    [self.operationQueue addOperationWithBlock:^{
        self.nextButtonOn = YES;
        while (self.nextButtonOn) {
            [self.animator grow:self.gotItButton withDuration:1];
            [self.animator sleep:1];
            [self.animator shrink:self.gotItButton withDuration:1];
            [self.animator sleep:1];
        }
    }];
    
    self.stage = 1;
}

@end
