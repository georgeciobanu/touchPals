//
//  TPElopeConnectionDelegate.h
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPInfoViewController;

@interface TPElopeConnectionDelegate : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *receivedData;
}

@property (nonatomic) TPInfoViewController *ivc;

- (id)initWithIVC:(TPInfoViewController *)infoVC;

@end
