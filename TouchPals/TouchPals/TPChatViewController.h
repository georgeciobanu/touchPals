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

@interface TPChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    IBOutlet UILabel *partnerNameField;
    IBOutlet UITableView *tv;
    IBOutlet UITextField *inputField;
}

@property (nonatomic) TPUser *user;
@property (nonatomic) NSMutableArray *chatMessages;

- (void)receiveNewEntry:(NSString *)text date:(NSDate *)timeSent;
- (void)loggedIn;

@end
