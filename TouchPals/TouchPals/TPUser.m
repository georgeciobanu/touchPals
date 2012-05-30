//
//  TPUser.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPUser.h"

@implementation TPUser

@synthesize username;
@synthesize email;
@synthesize userId;
@synthesize remainingSwaps;
@synthesize partnerUsername;

- (id)initWithUsername:(NSString *)u email:(NSString *)e userId:(NSInteger)uid remainingSwaps:(NSInteger) rs partnerUsername:(NSString *)p
{
    self = [super init];
    
    username = u;
    email = e;
    userId = uid;
    remainingSwaps = rs;
    partnerUsername = p;
    
    return self;
}

- (void)updateUsername:(NSString *)u
{
    [self setUsername:u];
}

- (void)decrementRemainingSwaps
{
    [self setRemainingSwaps:(remainingSwaps-1)];    
}


@end
