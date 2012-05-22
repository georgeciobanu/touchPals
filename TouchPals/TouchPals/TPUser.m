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
@synthesize remainingSwaps;
@synthesize partnerUsername;

- (id)initWithUsername:(NSString *)u email:(NSString *)e remainingSwaps:(NSInteger) rs partnerUsername:(NSString *)p
{
    self = [super init];
    
    username = u;
    email = e;
    remainingSwaps = rs;
    partnerUsername = p;
    
    return self;
}

- (void)updateUsername:(NSString *)u
{
    [self setUsername:u];
    
    NSLog(@"New username is %@", [self username]);
    
    // TODO: send message to server about the change
}

- (void)decrementRemainingSwaps
{
    remainingSwaps--;
    
    // TODO: let server know new number of swaps remaining
}


@end
