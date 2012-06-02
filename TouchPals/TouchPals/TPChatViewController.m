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
    [super viewWillAppear:animated];
    
    if ([self user] == nil) {
        TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate login];
    }
     
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)loggedIn
{
    
    NSLog(@"LoggedIn");
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [tv
     
     setBackgroundColor:[UIColor colorWithRed:242/255.0 green:239/255.0 blue:232/255.0 alpha:0.5
                         ]];
    
    
    NSString *partner = [user partnerUsername];
    if (!partner || [partner isEqual:[NSNull null]]) {
        [user setPartnerUsername:nil];
        [appDelegate searchingMatch];
    } else {
        [partnerNameField setText:[user partnerUsername]];
    }
    
    NSString *chatURL = [NSString stringWithFormat:@"%@/chats.json?auth_token=%@", [appDelegate domainURL], [appDelegate authToken]];
    
    NSURL *url = [NSURL URLWithString:chatURL];
    
    NSMutableURLRequest *chatRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:chatRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);

                               NSMutableArray *chats = (NSMutableArray *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];                 
                               
                               [chatMessages removeAllObjects];
                               [tv reloadData];
                               
                               NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                               [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"]; 


                               
                               
                               for (NSMutableDictionary *chat in chats) {
                                   
                                   NSString *dateString = [chat objectForKey:@"created_at"];                                   
                                   
                                   TPChatEntry *c = [[TPChatEntry alloc] initWithTimeSent:[dateFormat dateFromString:dateString]  text:[chat objectForKey:@"text"] userSent:([user userId] == [[chat objectForKey:@"sender_id"] intValue])];
                                   
                                   [chatMessages insertObject:c atIndex:0];                                   
                               }
                               
                               [tv performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];                               
                           }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    v.backgroundColor = [UIColor clearColor];
    [tv setTableHeaderView:v];
    [tv setTableFooterView:v];

    [self setChatMessages:[[NSMutableArray alloc] init]];
    [tv reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPChatEntry *c = [chatMessages objectAtIndex:[indexPath row]]; 
    
    if ([c userSent]) {
        TPTableViewCellUser *cell = (TPTableViewCellUser *) [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        
        if (!cell) {
            cell = [[TPTableViewCellUser alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
            
                        
            [cell.textLabel setTextColor:[UIColor colorWithRed:125.0f/255.0f green:113.0f/255.0f blue:117.0f/255.0f alpha:1.0f]];
            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];

            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:14.0];

        }
        
        [[cell textLabel] setText:[c text]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm a EEE, MMM d"];
        NSString *dateString = [dateFormat stringFromDate:[c timeSent]];
        
        
        [[cell detailTextLabel] setText:dateString];
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Georgia" size:11.0]];

        return cell;
    } else {
        TPTableViewCellPartner *cell = (TPTableViewCellPartner *) [tableView dequeueReusableCellWithIdentifier:@"PartnerCell"];
        
        if (!cell) {
            cell = [[TPTableViewCellPartner alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PartnerCell"];
            
            [cell.textLabel setTextColor:[UIColor colorWithRed:40.0f/255.0f green:111.0f/255.0f blue:183.0f/255.0f alpha:1.0f]];
            

            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:14.0];

        }
        
        [[cell textLabel] setText:[c text]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm a EEE, MMM d"];
        NSString *dateString = [dateFormat stringFromDate:[c timeSent]];
        
        [[cell detailTextLabel] setText:dateString];
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Georgia" size:11.0]];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [[chatMessages objectAtIndex:[indexPath row]] text];
    UIFont *cellFont = [UIFont fontWithName:@"Georgia" size:14.0];
    CGSize constraintSize = CGSizeMake(182, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 40;
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
    
    NSString *signupURL = [NSString stringWithFormat:@"%@/chats.json?auth_token=%@", [appDelegate domainURL], [appDelegate authToken]];
    
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
