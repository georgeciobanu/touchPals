//
//  TPFirstViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPChatViewController.h"
#import "TPAppDelegate.h"
#import "TPUser.h"
#import "TPChatEntry.h"
#import "TPTableViewCellUser.h"
#import "TPTableViewCellPartner.h"
#import "SRWebSocket.h"

@implementation TPChatViewController

@synthesize user;
@synthesize chatMessages;

- (void)viewWillAppear:(BOOL)animated
{
    if ([self user] == nil) {
        TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate login];
    }
}


- (void)loggedIn
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [chatMessages removeAllObjects];
    
    [tv reloadData];
    
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [tv setBackgroundColor:[UIColor colorWithRed:242/255.0 green:239/255.0 blue:232/255.0 alpha:1]];
    
    
    NSString *partner = [user partnerUsername];
    if (!partner || [partner isEqual:[NSNull null]]) {
        [user setPartnerUsername:nil];
        [appDelegate searchingMatch];
    } else {
        [partnerNameField setText:[user partnerUsername]];
    }
    
    [self setChatMessages:[[NSMutableArray alloc] init]];
    
    NSString *signupURL = [NSString stringWithFormat:@"http://localhost:3000/chats.json?auth_token=%@", [appDelegate authToken]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *signupRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:signupRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSMutableArray *chats = (NSMutableArray *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];                                
                               
                               for (NSMutableDictionary *chat in chats) {
                                   TPChatEntry *c = [[TPChatEntry alloc] initWithTimeSent:[[NSDate alloc] init]  text:[chat objectForKey:@"text"] userSent:([user userId] == [[chat objectForKey:@"sender_id"] intValue])];
                                   
                                   [chatMessages insertObject:c atIndex:0];
                                   
                                   NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
                                   
                                   
                                   
                                   [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
                               }
                                
                           }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setChatMessages:[[NSMutableArray alloc] init]];    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatMessages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[chatMessages objectAtIndex:[indexPath row]] text];
    UIFont *cellFont = [UIFont fontWithName:@"Georgia" size:14];
    CGSize constraintSize = CGSizeMake(180.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 20;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPChatEntry *c = [chatMessages objectAtIndex:[indexPath row]]; 
    
    if ([c userSent]) {
        TPTableViewCellUser *cell = (TPTableViewCellUser *) [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        
        if (!cell) {
            cell = [[TPTableViewCellUser alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
            
            [cell.textLabel setTextColor:[UIColor colorWithRed:125.0f/255.0f green:113.0f/255.0f blue:117.0f/255.0f alpha:1.0f]];

            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:14.0];

        }
        
        [[cell textLabel] setText:[c text]];
        
        return cell;
    } else {
        TPTableViewCellPartner *cell = (TPTableViewCellPartner *) [tableView dequeueReusableCellWithIdentifier:@"PartnerCell"];
        
        if (!cell) {
            cell = [[TPTableViewCellPartner alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PartnerCell"];
            
            [cell.textLabel setTextColor:[UIColor colorWithRed:40.0f/255.0f green:111.0f/255.0f blue:183.0f/255.0f alpha:1.0f]];

            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:14.0];

        }
        
        [[cell textLabel] setText:[c text]];
        
        return cell;
    }
        
    
}

- (void) receiveNewEntry:(NSString *)text date:(NSDate *)timeSent
{
    TPChatEntry *c = [[TPChatEntry alloc] initWithTimeSent:timeSent text:text userSent:NO];
    
    [chatMessages insertObject:c atIndex:0];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];

}

- (void) serverSendEntry:(TPChatEntry *)chatEntry
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *signupURL = [NSString stringWithFormat:@"http://localhost:3000/chats.json?auth_token=%@", [appDelegate authToken]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
            
    NSString *JSONString = [NSString stringWithFormat:@"{\"text\": \"%@\", \"sender_id\": \"%d\" }", [chatEntry text], [user userId]];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    usernameRequest.HTTPMethod = @"POST";
    [usernameRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    usernameRequest.HTTPBody = JSONBody;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:usernameRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);
                               
                           }];
}

- (void) sendNewEntry:(NSString *)text
{
    TPChatEntry *c = [[TPChatEntry alloc] initWithTimeSent:[[NSDate alloc] init] text:text userSent:YES];
    
    [chatMessages insertObject:c atIndex:0];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
    
    [self serverSendEntry:c];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([[textField text] length] > 0)
        [self sendNewEntry:[textField text]];
    
    [textField setText:@""];
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
