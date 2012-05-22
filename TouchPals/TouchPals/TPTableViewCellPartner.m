//
//  TPTableViewCellPartner.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPTableViewCellPartner.h"

@implementation TPTableViewCellPartner
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect cellFrame = [self frame];
    
    CGFloat tableWidth = CGRectGetWidth(cellFrame);
    
    CGRect labelFrame = [self.textLabel frame];
    
    labelFrame.size.width = 0.65*tableWidth;
    
    [self.textLabel setFrame:labelFrame];
}

@end
