//
//  TPSecondViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class TPUser;

@interface TPInfoViewController : UIViewController <UITextFieldDelegate, SKProductsRequestDelegate, UIAlertViewDelegate, SKPaymentTransactionObserver>
{
    IBOutlet UILabel *partnerNameField;
    IBOutlet UITextField *usernameField;
    
    SKProduct *elopeProduct;
    
    UIAlertView *buyAlert;
    UIAlertView *elopeAlert;
    __weak IBOutlet UITextField *inviteEmailField;
    
    
}

@property (nonatomic) IBOutlet UILabel *remainingField;

@property (nonatomic) TPUser *user;


- (IBAction)getNewPartner:(id)sender;
- (IBAction)updateUsername:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)inviteFriend:(id)sender;
- (IBAction)reportPartner:(id)sender;

@end
