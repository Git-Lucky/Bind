
#import <Foundation/Foundation.h>

@class HISTransitionAnimator;

@interface HISTransitioningController : NSObject <UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) HISTransitionAnimator *animator;

- (instancetype)initWithAnimator:(HISTransitionAnimator *)animator;

@end
