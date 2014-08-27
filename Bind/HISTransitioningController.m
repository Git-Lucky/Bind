
#import "HISTransitioningController.h"
#import "HISTransitionAnimator.h"

@implementation HISTransitioningController

- (instancetype)initWithAnimator:(HISTransitionAnimator *)animator
{
    self = [super init];
    if (self) {
        self.animator = animator;
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animator.isPresenting = YES;
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animator.isPresenting = NO;
    return self.animator;
}

@end
