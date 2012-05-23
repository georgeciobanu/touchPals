//
//  TPLoginViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPLoginViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    IBOutlet UILabel *error;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (void)loginWithEmail:(NSString *)e password:(NSString *)p;


@end
