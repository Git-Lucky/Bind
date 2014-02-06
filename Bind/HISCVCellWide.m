//
//  HISCVCellWide.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCVCellWide.h"

@implementation HISCVCellWide

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

- (void)setBuddy:(HISBuddy *)buddy
{
    _buddy = buddy;
    
    if (self.buddy.pic) {
        self.imageView.image = self.buddy.pic;
    }
    else if (self.buddy.imagePath) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.imageView.image = nil;
    }
    
    self.name.text = self.buddy.name;
    self.affinity.value = self.buddy.affinity;
}

@end
