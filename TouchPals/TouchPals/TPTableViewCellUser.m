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
            
    CGRect labelFrame = [self.textLabel frame];
    
    labelFrame.size.width = 260.0f;
    
    labelFrame.origin.x += 0.3*labelFrame.size.width;
    labelFrame.size.width -= 0.3*labelFrame.size.width;
    
    NSString *cellText = [self.textLabel text];
    UIFont *cellFont = [self.textLabel font];
    CGSize constraintSize = CGSizeMake(labelFrame.size.width, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];

    labelFrame.size.height = labelSize.height;
    labelFrame.origin.y = 12;
    
    [self.textLabel setFrame:labelFrame];
        
     NSInteger y = (labelFrame.origin.y + labelFrame.size.height + 4);
    
    CGRect detailFrame = [self.detailTextLabel frame];
    
    detailFrame.origin.y = y;
    detailFrame.origin.x += 0.55*260.0f;
    
    [self.detailTextLabel setFrame:detailFrame];    
}
@end
