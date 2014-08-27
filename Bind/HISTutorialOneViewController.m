//
//  HISTutorialOneViewController.m
//  Bind
//
//  Created by Tim Hise on 3/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISTutorialOneViewController.h"
#import "UIImage+ImageEffects.h"
#import "Animator.h"
#import "AnimatorOperationQueue.h"

@interface HISTutorialOneViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcome;
@property (weak, nonatomic) IBOutlet UILabel *add;
@property (weak, nonatomic) IBOutlet UILabel *friend;
@property (weak, nonatomic) IBOutlet UILabel *started;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *insideCircleTextPart1;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *insideCircleTextPart2;
@property (weak, nonatomic) IBOutlet UILabel *useWiselyLabel;

@property (weak, nonatomic) IBOutlet UIView *addFriendButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *innerCircle;
@property (weak, nonatomic) IBOutlet UIImageView *whiteCircle;
@property (weak, nonatomic) IBOutlet UIImageView *whiteFillImageView;
@property (strong, nonatomic) NSArray *animationArray;
@property (nonatomic) BOOL onScreen;

@end

@implementation HISTutorialOneViewController

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
    
    [self processAndDisplayBackgroundImage:[UIImage imageNamed:@"bluebubblesglow.jpg"]];
    
    self.welcome.alpha = 0.f;
    self.add.alpha = 0.f;
    self.friend.alpha = 0.f;
    self.started.alpha = 0.f;
    self.whiteCircle.alpha = 0.f;
    self.addFriendButtonView.alpha = 0.f;
    self.plusImageView.layer.cornerRadius = self.plusImageView.frame.size.width / 2;
    self.plusImageView.layer.masksToBounds = YES;
    
    for (UILabel *letter in self.innerCircle) {
        letter.alpha = 0.f;
    }
    
    self.onScreen = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showIntro];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)processAndDisplayBackgroundImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [image drawInRect:self.view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}
- (IBAction)addFriend:(id)sender {
    self.onScreen = NO;
    
    [[AnimatorOperationQueue sharedOperationQueue] cancelAllOperations];
    
    [self performSegueWithIdentifier:@"createFriend1" sender:self];
}

- (IBAction)reanimate:(id)sender {
    [self showIntro];
}

- (void)showIntro
{
    Animator *animator = [[Animator alloc] init];
    
    AnimatorOperationQueue *operationQueue = [AnimatorOperationQueue sharedOperationQueue];
    
    [operationQueue setMaxConcurrentOperationCount:1];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:.6];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:.5];
        [animator fadeIn:self.welcome withDuration:.4];
        [animator shrink:self.welcome withDuration:.4];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:.4f];
    }];
    
    for (UILabel *letter in self.innerCircle) {
        [operationQueue addOperationWithBlock:^{
            [animator sleep:.1f];
            [animator fadeIn:letter withDuration:.4];
            [animator shrink:letter withDuration:.4];
        }];
    }
    
    [operationQueue addOperationWithBlock:^{
        [animator fadeIn:self.whiteCircle withDuration:2];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:2];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator fadeIn:self.whiteFillImageView withDuration:2];
        [animator sleep:2];
    }];
    
    [operationQueue addOperationWithBlock:^{
        for (UILabel *label in self.insideCircleTextPart1) {
            [animator fadeIn:label withDuration:.4];
//            [animator grow:label withDuration:.4];
        }
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:2];
    }];
    
    [operationQueue addOperationWithBlock:^{
        for (UILabel *label in self.insideCircleTextPart2) {
            [animator fadeIn:label withDuration:.4];
//            [animator grow:label withDuration:.4];
        }
        [animator sleep:2];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator fadeIn:self.useWiselyLabel withDuration:.4];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:2];
        [animator fadeIn:self.add withDuration:.4];
        [animator shrink:self.add withDuration:.4];
        
        [animator fadeIn:self.friend withDuration:.4];
        [animator shrink:self.friend withDuration:.4];
        
        [animator fadeIn:self.started withDuration:.4];
        [animator shrink:self.started withDuration:.4];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:1.2];
        [animator fadeIn:self.addFriendButtonView withDuration:.4];
        [animator shrink:self.addFriendButtonView withDuration:.4];
    }];
    
    [operationQueue addOperationWithBlock:^{
        while (self.onScreen) {
            [animator grow:self.addFriendButtonView withDuration:1];
            [animator sleep:1];
            [animator shrink:self.addFriendButtonView withDuration:1];
            [animator sleep:1];
        }
    }];
}


@end
