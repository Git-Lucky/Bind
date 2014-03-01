//
//  HISSearchHeader.m
//  Bind
//
//  Created by Tim Hise on 3/1/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISSearchHeader.h"

@interface HISSearchHeader ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

@end

@implementation HISSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
