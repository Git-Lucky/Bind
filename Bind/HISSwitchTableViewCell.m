//
//  HISSwitchTableViewCell.m
//  Bind
//
//  Created by Tim Hise on 2/22/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISSwitchTableViewCell.h"

@implementation HISSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
