//
//  TPSecondViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPInfoViewController.h"
#import "TPUser.h"
#import "TPAppDelegate.h"

@implementation TPInfoViewController

@synthesize user;

- (IBAction)updateUsername:(id)sender
{
    NSLog(@"Button Worked");
    [user updateUsername:[usernameField text]];
}

- (IBAction)getNewPartner:(id)sender
{    
    if ([user remainingSwaps] > 0) {
        // TODO: get a new partner
        
        [user decrementRemainingSwaps];
        [partnerNameField setText:[NSString stringWithFormat:@"Partner: %@", [user partnerUsername]]];        
        [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
        
    } else {
        // TODO: Ask if wants to buy extra swaps
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
    [self setUser:[appDelegate user]];
    
    [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    [partnerNameField setText:[NSString stringWithFormat:@"Partner: %@", [user partnerUsername]]];
    [usernameField setText:[user username]];    
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
