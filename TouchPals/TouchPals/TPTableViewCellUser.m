//
//  TPTableViewCellUser.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPTableViewCellUser.h"

@implementation TPTableViewCellUser
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect cellFrame = [self frame];
    
    CGFloat tableWidth = CGRectGetWidth(cellFrame);
    
    CGRect labelFrame = [self.textLabel frame];
        
    labelFrame.size.width = 0.65*tableWidth;
    labelFrame.origin.x = 0.3*tableWidth;
    
    [self.textLabel setFrame:labelFrame];
}
@end
