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

@interface HISTutorialTwoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *first;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *second;



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

    [self processAndDisplayBackgroundImage:[UIImage imageNamed:@"createFriendBlurredTop"]];
    
    for (UILabel *sentence in self.first) {
        sentence.alpha = 0;
    }
    
    for (UILabel *sentence in self.second) {
        sentence.alpha = 0;
    }
    
    self.nextButton.alpha = 0;
    
    self.nextButton.layer.cornerRadius = self.nextButton.frame.size.height / 2;
    self.nextButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.nextButton.layer.borderWidth = 2;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showIntro];
}

- (void)processAndDisplayBackgroundImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [image drawInRect:self.view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (IBAction)toContinue1:(id)sender {
    [self continue1];
}

- (void)showIntro
{
    Animator *animator = [[Animator alloc] init];
    
    AnimatorOperationQueue *operationQueue = [AnimatorOperationQueue sharedOperationQueue];
    
    [operationQueue setMaxConcurrentOperationCount:1];
    
    [operationQueue addOperationWithBlock:^{
        for (UILabel *sentence in self.first) {
            [animator sleep:.5];
            [animator fadeIn:sentence withDuration:.4];
            [animator shrink:sentence withDuration:.4];
        }
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:1];
    }];
    
    [operationQueue addOperationWithBlock:^{
        [animator sleep:.5];
        [animator fadeIn:self.nextButton withDuration:.4];
        [animator shrink:self.nextButton withDuration:.4];
    }];
    
    [operationQueue addOperationWithBlock:^{
        while (true) {
            [animator grow:self.nextButton withDuration:1];
            [animator sleep:1];
            [animator shrink:self.nextButton withDuration:1];
            [animator sleep:1];
        }
    }];

}

- (void)continue1
{
    Animator *animator = [[Animator alloc] init];
    
    AnimatorOperationQueue *operationQueue = [AnimatorOperationQueue sharedOperationQueue];
    
    [operationQueue cancelAllOperations];
    
    [operationQueue setMaxConcurrentOperationCount:1];
    
    [operationQueue addOperationWithBlock:^{
        for (UILabel *sentence in self.first) {
            [animator sleep:.5];
            [animator fadeIn:sentence withDuration:.4];
            [animator shrink:sentence withDuration:.4];
        }
    }];
}

@end
