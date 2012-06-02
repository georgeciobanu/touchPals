//
//  TPDeviceTokenConnectionDelegate.h
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDeviceTokenConnectionDelegate : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}

@end
