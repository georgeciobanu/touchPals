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

@implementation TPChatViewController

@synthesize user;
@synthesize chatMessages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self setUser:[appDelegate user]];
    
    [partnerNameField setText:[user partnerUsername]];
        
    [self setChatMessages:[[NSMutableArray alloc] init]];
    
    TPChatEntry *c1 = [[TPChatEntry alloc] initWithTimeSent:[[NSDate alloc] init] text:@"Hi Jane! What are you up to? My name is Jonathan but I got by Johnny :-)" userSent:YES];
    TPChatEntry *c2 = [[TPChatEntry alloc] initWithTimeSent:[[NSDate alloc] init] text:@"Hi Johnny! My name isn't really Jane, but I got by that because I think I am a plain Jane... :-(" userSent:NO];
    
    [chatMessages addObject:c2];
    [chatMessages addObject:c1];
    
    [tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
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
            
            [cell.textLabel setTextColor:[UIColor colorWithRed:182.0f/255.0f green:44.0f/255.0f blue:47.0f/255.0f alpha:1.0f]];
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
            
            [cell.textLabel setTextColor:[UIColor colorWithRed:94.0f/255.0f green:97.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:14.0];

        }
        
        [[cell textLabel] setText:[c text]];
        
        return cell;
    }
        
    
}

- (void) sendNewEntry:(NSString *) text
{
    TPChatEntry *c = [[TPChatEntry alloc] initWithTimeSent:[[NSDate alloc] init] text:text userSent:YES];
    
    [chatMessages insertObject:c atIndex:0];
    
    [tv reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([[textField text] length] > 0)
        [self sendNewEntry:[textField text]];
    
    [textField setText:@""];
    
    return YES;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
