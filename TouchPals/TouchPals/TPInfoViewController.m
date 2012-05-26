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

- (void) logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate login];
}

- (void) serverUpdateUsername:(NSString*)u
{    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    
    NSString *signupURL = [NSString stringWithFormat:@"http://localhost:3000/users.json?auth_token=%@", [appDelegate authToken]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"username\": \"%@\" }", u];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    usernameRequest.HTTPMethod = @"PUT";
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

- (IBAction)updateUsername:(id)sender
{
    NSString *newUsername = [usernameField text];
    
    [user updateUsername:[usernameField text]];
    
    [self serverUpdateUsername:newUsername];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
    
    if ([appDelegate user] == nil) {
        [appDelegate login];
        return;
    }
    
    [self setUser:[appDelegate user]];
    
    [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    [partnerNameField setText:[NSString stringWithFormat:@"Partner: %@", [user partnerUsername]]];
    [usernameField setText:[user username]];    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
