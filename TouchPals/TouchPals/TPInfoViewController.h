//
//  TPSecondViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPUser;

@interface TPInfoViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *remainingField;
    IBOutlet UILabel *partnerNameField;
    IBOutlet UITextField *usernameField;
}

@property (nonatomic) TPUser *user;

- (IBAction)getNewPartner:(id)sender;
- (IBAction)updateUsername:(id)sender;
- (IBAction)logout:(id)sender;

@end
