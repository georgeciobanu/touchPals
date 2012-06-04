//
//  TPFirstViewController.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TPTableViewController;
@class TPUser;

@interface TPChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UILabel *partnerNameField;
    IBOutlet UITableView *tv;
    IBOutlet UITextField *inputField;
    
    NSMutableData *receivedData;
}

@property (nonatomic) TPUser *user;
@property (nonatomic) NSMutableArray *chatMessages;
- (IBAction)backgroundTapped:(id)sender;

- (void)receiveNewEntry:(NSString *)text date:(NSDate *)timeSent;
- (void)loggedIn;

@end
