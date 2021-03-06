//
//  TPLoginViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface TPLoginViewController : UIViewController <UITextFieldDelegate, SRWebSocketDelegate, NSURLConnectionDelegate>
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    IBOutlet UILabel *error;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    NSMutableData *receivedData;
    NSStringEncoding encoding;

}

@property (nonatomic, assign) BOOL signedIn;

- (void)startWebSocketWithAuthToken:(NSString *)authToken;
- (IBAction)backgroundTapped:(id)sender;

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (void)loginWithEmail:(NSString *)e password:(NSString *)p;
- (void)reconnectSocket;

@end
