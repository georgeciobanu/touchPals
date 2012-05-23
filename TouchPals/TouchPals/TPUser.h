//
//  TPUser.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPUser : NSObject

@property (nonatomic) NSString *username;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSInteger remainingSwaps;
@property (nonatomic) NSString *partnerUsername;
@property (nonatomic, readonly) NSInteger userId;

- (void)updateUsername:(NSString *)u;

- (void)decrementRemainingSwaps;

- (id)initWithUsername:(NSString *)u email:(NSString *)e userId:(NSInteger)uid remainingSwaps:(NSInteger) rs partnerUsername:(NSString *)p;

@end
