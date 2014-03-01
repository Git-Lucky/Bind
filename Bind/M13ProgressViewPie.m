//
//  M13ProgressViewPie.m
//  M13ProgressView
//
/*Copyright (c) 2013 Brandon McQuilkin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "M13ProgressViewPie.h"

@interface M13ProgressViewPie ()

/**The start progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationFromValue;
/**The end progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationToValue;
/**The start time interval for the animaiton.*/
@property (nonatomic, assign) CFTimeInterval animationStartTime;
/**Link to the display to keep animations in sync.*/
@property (nonatomic, strong) CADisplayLink *displayLink;
/**Allow us to write to the progress.*/
@property (nonatomic, readwrite) CGFloat progress;
/**The layer that progress is shown on.*/
@property (nonatomic, retain) CAShapeLayer *progressLayer;
/**The layer that the background and indeterminate progress is shown on.*/
@property (nonatomic, retain) CAShapeLayer *backgroundLayer;
/**The layer that is used to render icons for success or failure.*/
@property (nonatomic, retain) CAShapeLayer *iconLayer;
/**The layer that is used to display the indeterminate view.*/
@property (nonatomic, retain) CAShapeLayer *indeterminateLayer;
/**The action currently being performed.*/
@property (nonatomic, assign) M13ProgressViewAction currentAction;

@property (nonatomic, strong) UILabel *label;
@end

#define kM13ProgressViewPieHideKey @"Hide"
#define kM13ProgressViewPieShowKey @"Show"

@implementation M13ProgressViewPie
{
    //Wether or not the corresponding values have been overriden by the user
    BOOL _backgroundRingWidthOverriden;
}

#pragma mark Initalization and setup

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //Set own background color
    self.backgroundColor = [UIColor clearColor];
    
    //Set defaut sizes
    _backgroundRingWidthOverriden = NO;
    _backgroundRingWidth = 0;//fmaxf(self.bounds.size.width * .025, 1.0);
    
    self.animationDuration = 2;
    
    //Set default colors
    self.primaryColor = [UIColor colorWithRed:0.000 green:1.000 blue:0.089 alpha:1.000];
    self.secondaryColor = self.primaryColor;
    
    //Set up the background layer
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.strokeColor = self.primaryColor.CGColor; //self.secondaryColor.CGColor;
    _backgroundLayer.fillColor = [[UIColor clearColor] CGColor];
    _backgroundLayer.lineCap = kCALineCapRound;
    _backgroundLayer.lineWidth = _backgroundRingWidth;
    [self.layer addSublayer:_backgroundLayer];
    
    //Set up the progress layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.fillColor = self.primaryColor.CGColor;
    _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:_progressLayer];
    
    //Set the indeterminate layer
    _indeterminateLayer = [CAShapeLayer layer];
    _indeterminateLayer.fillColor = self.primaryColor.CGColor;
    _indeterminateLayer.opacity = 0;
    [self.layer addSublayer:_indeterminateLayer];
    
    //Set up the icon layer
    _iconLayer = [CAShapeLayer layer];
    _iconLayer.fillColor = self.primaryColor.CGColor;
    _iconLayer.fillRule = kCAFillRuleNonZero;
    [self.layer addSublayer:_iconLayer];
    
    _label = [[UILabel alloc] initWithFrame:self.frame];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120.f];
//    [self.layer addSublayer:_label.layer];
}

#pragma mark Appearance

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    [super setPrimaryColor:primaryColor];
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _progressLayer.fillColor   = self.primaryColor.CGColor;
    _iconLayer.fillColor = self.primaryColor.CGColor;
    _indeterminateLayer.fillColor = self.primaryColor.CGColor;
    _backgroundLayer.strokeColor = self.primaryColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    [super setSecondaryColor:secondaryColor];
    _backgroundLayer.strokeColor = self.secondaryColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setBackgroundRingWidth:(CGFloat)backgroundRingWidth
{
    _backgroundRingWidth = backgroundRingWidth;
    _backgroundLayer.lineWidth = _backgroundRingWidth;
    _backgroundRingWidthOverriden = YES;
    [self setNeedsDisplay];
}

- (UIColor *)getTransitionColor:(float)progress
{
    CGFloat r1,g1,b1,a1;
    [[UIColor colorWithRed:0.337 green:1.000 blue:0.000 alpha:1.000] getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat r2,g2,b2,a2;
    [[UIColor colorWithRed:1.000 green:0.936 blue:0.001 alpha:1.000] getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat r3,g3,b3,a3;
    [[UIColor colorWithRed:0.888 green:0.272 blue:0.007 alpha:1.000] getRed:&r3 green:&g3 blue:&b3 alpha:&a3];
    
    CGFloat r,g,b,a;
    if (progress < .5f) {
        progress *= 2;
        r = r3-progress*(r3-r2);
        g = g3-progress*(g3-g2);
        b = b3-progress*(b3-b2);
        a = a3-progress*(a3-a2);
    } else {
        progress *= (progress - .5) * 2;
        r = r2-progress*(r2-r1);
        g = g2-progress*(g2-g1);
        b = b2-progress*(b2-b1);
        a = a2-progress*(a2-a1);
    }
        
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

#pragma mark Actions

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (self.progress == progress) {
        return;
    }
    if (animated == NO) {
//        [self bringSublayerToFront:_label.layer];
        if (_displayLink) {
            //Kill running animations
            [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            _displayLink = nil;
        }
        [super setProgress:progress animated:animated];
        [self setPrimaryColor:[self getTransitionColor:progress]];
        [self setNeedsDisplay];
    } else {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue = progress;
        
        if (!_displayLink) {
            //Create and setup the display link
            [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        } /*else {
           //Reuse the current display link
           }*/
    }
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGFloat dt = (displayLink.timestamp - _animationStartTime) / self.animationDuration;
        if (dt >= 1.0) {
            //Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an animation in progress and try to stop it by itself. Once over one, set to actual progress amount. Animation is over.
            [self.displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
            self.displayLink = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [super setProgress:_animationToValue animated:NO];
                [self setNeedsDisplay];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Set progress
            [self setPrimaryColor:[self getTransitionColor:_animationFromValue + dt * (_animationToValue - _animationFromValue)]];
            [super setProgress:_animationFromValue + dt * (_animationToValue - _animationFromValue) animated:YES];
            [self setNeedsDisplay];
        });
        
    });
}

- (void)performAction:(M13ProgressViewAction)action animated:(BOOL)animated
{
    if (action == M13ProgressViewActionNone && _currentAction != M13ProgressViewActionNone) {
        //Animate
        [CATransaction begin];
        [_iconLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
        if (self.indeterminate) {
            [_indeterminateLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
        } else {
            [_progressLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
        }
        [CATransaction commit];
        _currentAction = action;
    } else if (action == M13ProgressViewActionSuccess && _currentAction != M13ProgressViewActionSuccess) {
        if (_currentAction == M13ProgressViewActionNone) {
            _currentAction = action;
            //Just show the icon layer
            [self drawIcon];
            //Animate
            [CATransaction begin];
            [_iconLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
            if (self.indeterminate) {
                [_indeterminateLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            } else {
               [_progressLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            }
            [CATransaction commit];
        } else if (_currentAction == M13ProgressViewActionFailure) {
            //Hide the icon layer before showing
            [CATransaction begin];
            [_label.layer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            [_iconLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            [CATransaction setCompletionBlock:^{
                _currentAction = action;
                [self drawIcon];
                [_iconLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
            }];
            [CATransaction commit];
        }
    } else if (action == M13ProgressViewActionFailure && _currentAction != M13ProgressViewActionFailure) {
        if (_currentAction == M13ProgressViewActionNone) {
            //Just show the icon layer
            _currentAction = action;
            [self drawIcon];
            [CATransaction begin];
            [_iconLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
            if (self.indeterminate) {
                [_indeterminateLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            } else {
                [_progressLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            }
            [CATransaction commit];
        } else if (_currentAction == M13ProgressViewActionSuccess) {
            //Hide the icon layer before showing
            [CATransaction begin];
            [_iconLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
            [CATransaction setCompletionBlock:^{
                _currentAction = action;
                [self drawIcon];
                [_iconLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
            }];
            [CATransaction commit];
        }
    }
}

- (void)setIndeterminate:(BOOL)indeterminate
{
    [super setIndeterminate:indeterminate];
    if (self.indeterminate == YES) {
        //Draw the indeterminate circle
        [self drawIndeterminate];
        
        //Create the rotation animation
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        //Set the animations
        [_indeterminateLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        [CATransaction begin];
        [_progressLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
        [_indeterminateLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
        [CATransaction commit];
    } else {
        //Animate
        [CATransaction begin];
        [_progressLayer addAnimation:[self showAnimation] forKey:kM13ProgressViewPieShowKey];
        [_indeterminateLayer addAnimation:[self hideAnimation] forKey:kM13ProgressViewPieHideKey];
        [CATransaction setCompletionBlock:^{
            //Remove the rotation animation and reset the background
            [_backgroundLayer removeAnimationForKey:@"rotationAnimation"];
            [self drawBackground];
        }];
        [CATransaction commit];
    }
}

- (CABasicAnimation *)showAnimation
{
    //Show the progress layer and percentage
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.duration = self.animationDuration;
    showAnimation.repeatCount = 1.0;
    //Prevent the animation from resetting
    showAnimation.fillMode = kCAFillModeForwards;
    showAnimation.removedOnCompletion = NO;
    return showAnimation;
}

- (CABasicAnimation *)hideAnimation
{
    //Hide the progress layer and percentage
    CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.duration = self.animationDuration;
    hideAnimation.repeatCount = 1.0;
    //Prevent the animation from resetting
    hideAnimation.fillMode = kCAFillModeForwards;
    hideAnimation.removedOnCompletion = NO;
    return hideAnimation;
}

#pragma mark Layout

- (void)layoutSubviews
{
    //Update frames of layers
    _backgroundLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;
    _indeterminateLayer.frame = self.bounds;
    
    //Update line widths if not overriden
    if (!_backgroundRingWidthOverriden) {
        _backgroundRingWidth = fmaxf(self.frame.size.width * .025, 1.0);
    }
    
    //Redraw
    [self setNeedsDisplay];
}

//- (void)setFrame:(CGRect)frame
//{
//    //Keep the progress view square.
//    if (frame.size.width != frame.size.height) {
//        frame.size.height = frame.size.width;
//    }
//    [super setFrame:frame];
//}


#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //Draw the background
    [self drawBackground];
    
    //Draw Icons
    [self drawIcon];
    
    //Draw Progress
    [self drawProgress];
}

- (void)drawSuccess
{
    //Draw relative to a base size and percentage, that way the check can be drawn for any size.*/
    CGFloat radius = (self.frame.size.width / 2.0);
    CGFloat size = radius * .3;
    
    //Create the path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, size * 2)];
    [path addLineToPoint:CGPointMake(size * 3, size * 2)];
    [path addLineToPoint:CGPointMake(size * 3, size)];
    [path addLineToPoint:CGPointMake(size, size)];
    [path addLineToPoint:CGPointMake(size, 0)];
    [path closePath];
    
    //Rotate it through -45 degrees...
    [path applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    
    //Center it
    [path applyTransform:CGAffineTransformMakeTranslation(radius * .46, 1.02 * radius)];
    
    //Set path
    [_iconLayer setPath:path.CGPath];
    [_iconLayer setFillColor:self.primaryColor.CGColor];
}

- (void)drawFailure
{
    //Calculate the size of the X
    CGFloat radius = self.frame.size.width / 2.0;
    CGFloat size = radius * .3;
    
    //Create the path for the X
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    [xPath moveToPoint:CGPointMake(size, 0)];
    [xPath addLineToPoint:CGPointMake(2 * size, 0)];
    [xPath addLineToPoint:CGPointMake(2 * size, size)];
    [xPath addLineToPoint:CGPointMake(3 * size, size)];
    [xPath addLineToPoint:CGPointMake(3 * size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(2 * size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(2 * size, 3 * size)];
    [xPath addLineToPoint:CGPointMake(size, 3 * size)];
    [xPath addLineToPoint:CGPointMake(size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(0, 2 * size)];
    [xPath addLineToPoint:CGPointMake(0, size)];
    [xPath addLineToPoint:CGPointMake(size, size)];
    [xPath closePath];
    
    //Center it
    [xPath applyTransform:CGAffineTransformMakeTranslation(radius - (1.5 * size), radius - (1.5 * size))];
    
    //Rotate path
    [xPath applyTransform:CGAffineTransformMake(cos(M_PI_4),sin(M_PI_4),-sin(M_PI_4),cos(M_PI_4),radius * (1 - cos(M_PI_4)+ sin(M_PI_4)),radius * (1 - sin(M_PI_4)- cos(M_PI_4)))];
    
    //Set path and fill color
    [_iconLayer setPath:xPath.CGPath];
    [_iconLayer setFillColor:self.primaryColor.CGColor];
}

- (void)drawBackground
{
    //Create parameters to draw background
    float startAngle = - M_PI_2;
    float endAngle = startAngle + (2.0 * M_PI);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;
    
    //Draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = _backgroundRingWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    //Set the path
    _backgroundLayer.path = path.CGPath;
}

- (void)drawProgress
{
    //Create parameters to draw progress
    float startAngle = - M_PI_2;
    float endAngle = startAngle + (2.0 * M_PI * self.progress);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;
    
    //Draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)];
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path closePath];
    
    [_label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120.f]];
    [_label setTextColor:[UIColor whiteColor]];
    [_label setBackgroundColor:[UIColor clearColor]];
    [_label setText:[NSString stringWithFormat:@"%.2f %%", self.progress * 100.f]];
    
    //Set the path
    [_progressLayer setPath:path.CGPath];
    
}

- (void)drawIcon
{
    if (_currentAction == M13ProgressViewActionSuccess) {
        [self drawSuccess];
    } else if (_currentAction == M13ProgressViewActionFailure) {
        [self drawFailure];
    } else if (_currentAction == M13ProgressViewActionNone) {
        //Clear layer
        _iconLayer.path = nil;
    }
}

- (void)drawIndeterminate
{
    //Create parameters to draw progress
    float startAngle = - M_PI_2;
    float endAngle = startAngle + (2.0 * M_PI * .2);
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;
    
    //Draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)];
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path closePath];
    
    //Set the path
    [_indeterminateLayer setPath:path.CGPath];
}

#pragma mark - CALayerAdditions

- (void)bringSublayerToFront:(CALayer *)layer {
    [layer removeFromSuperlayer];
    [self.layer insertSublayer:layer atIndex:(int)[self.layer.sublayers count]-1];
}

- (void)sendSublayerToBack:(CALayer *)layer {
    [layer removeFromSuperlayer];
    [self.layer insertSublayer:layer atIndex:0];
}

@end
