//
//  TPSignupViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPSignupViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UILabel *error;
    
    NSMutableData *receivedData;
}

- (IBAction)backgroundTapped:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)login:(id)sender;

@end
