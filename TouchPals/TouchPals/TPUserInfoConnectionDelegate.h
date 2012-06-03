//
//  TPUserInfoConnectionDelegate.h
//  ChatAffair
//
//  Created by Jonathan Cottrell on 12-06-02.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPUserInfoConnectionDelegate : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}
@end
