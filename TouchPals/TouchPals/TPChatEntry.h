//
//  TPChatEntry.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPChatEntry : NSObject

@property (nonatomic) NSDate *timeSent;
@property (nonatomic) NSString *text;
@property (nonatomic) BOOL userSent;

- (id)initWithTimeSent:(NSDate *)time text:(NSString *)t userSent:(BOOL)us;

@end
