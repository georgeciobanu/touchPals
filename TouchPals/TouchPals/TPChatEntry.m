//
//  TPChatEntry.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPChatEntry.h"

@implementation TPChatEntry

@synthesize timeSent;
@synthesize text;
@synthesize userSent;

- (id)initWithTimeSent:(NSDate *)time text:(NSString *)t userSent:(BOOL)us
{
    self = [super init];
    
    if(self) {
        timeSent = time;
        text = t;
        userSent = us;
    }
    
    return self;
}

@end
