//
//  TPLoginViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-22.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPLoginViewController.h"
#import "TPAppDelegate.h"
#import "TPUser.h"

@implementation TPLoginViewController

- (void)loginWithEmail:(NSString *)e password:(NSString *)p
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *loginURL = @"http://localhost:3000/sessions";
    
    NSURL *url = [NSURL URLWithString:loginURL];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"user\": {\"email\":\"%@\",\"password\":\"%@\"}}", e, p];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    loginRequest.HTTPMethod = @"POST";
    [loginRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [loginRequest addValue: @"application/json" forHTTPHeaderField:@"Accept"];
    loginRequest.HTTPBody = JSONBody;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:loginRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *errors){
                               
                               
                               // FOR DEBUGGING
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);
                               
                               NSMutableDictionary *json1 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errors];
                               
                               
                               NSString *auth_token = [(NSMutableDictionary *)[json1 objectForKey:@"session"] objectForKey:@"auth_token"];
                               
                               [appDelegate setAuthToken:auth_token];
                               
                               NSMutableDictionary *json2 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errors];
                               
                               
                               NSMutableDictionary *userJSON = (NSMutableDictionary *)[json2 objectForKey:@"user"];
                               
                               NSString *e = [userJSON objectForKey:@"email"];
                               NSString *u = [userJSON objectForKey:@"username"];
                               
                               if (u == (NSString *)[NSNull null])
                                   u = [NSString stringWithFormat:@"Anonymous"];
                               
                               
                               NSInteger i = [[userJSON objectForKey:@"id"] intValue];
                               
                               // TODO: GET REMAINING SWAPS
                               NSInteger rs = 0;
                               // NSInteger rs = [[userJSON objectForKey:@"remainingSwaps"] intValue];
                               
                               
                               //NSInteger pid = [[userJSON objectForKey:@"partner_id"] intValue];
                               // TODO: get partner name from partner ID
                                                              
                               //temporary
                               NSString *pn = [NSString stringWithFormat:@"Jane - hardcoded"];
                               
                               [appDelegate setUser:[[TPUser alloc] initWithUsername:u email:e userId:i remainingSwaps:rs partnerUsername:pn]];
                               
                               [appDelegate home];
                               
                           }];
    

}

- (IBAction)login:(id)sender
{
    
    NSString *e = [email text];
    NSString *p = [password text];

    if ([e length] > 0 && [p length] > 0) {
        
        [self loginWithEmail:e password:p];
        [activityIndicator startAnimating];
        
                
    } else {
        [error setText:@"Enter email and password"];
    }
}

- (IBAction)signup:(id)sender
{
    
    TPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate signup];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == email) {
        [password becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}
@end
