//
//  TPSignupViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPSignupViewController.h"
#import "TPAppDelegate.h"

@implementation TPSignupViewController

- (IBAction)login:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate login];
}

- (IBAction)signup:(id)sender
{
    if ([[email text] length] < 3) {
        [error setText:@"Invalid Email"];
        return;
    }
    
    if ([[password text] length] < 6) {
        [error setText:@"Password must be at least 6 characters"];
        return;
    }
    
    if ([[username text] length] < 1) {
        [error setText:@"Specify a username! (you can change it later)"];
        return;
    }
    
    NSLog(@"Validation of Signup passed");
    
    NSString *e = [email text];
    NSString *p = [password text];
    NSString *u = [username text];
    
    NSLog(@"%@, %@, %@", e, p, u);
    
    TPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    // TODO: make a call to server to signup
    NSString *signupURL = @"http://localhost:3000/users";
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"user\": {\"email\":\"%@\",\"password\":\"%@\",\"password_confirmation\":\"%@\", \"username\":\"%@\"}}", e, p, p, u];
        
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *signupRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    signupRequest.HTTPMethod = @"POST";
    [signupRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [signupRequest addValue: @"application/json" forHTTPHeaderField:@"Accept"];
    signupRequest.HTTPBody = JSONBody;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:signupRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               
                               // Manage the response here.
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);
                               
                               // TODO: replace this with manual login
                               [delegate loginWithEmail:e password:p];
                               
                           }];

    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == email) {
        [password becomeFirstResponder];
    } else if (textField == password){
        [username becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}


@end
