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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}


- (void)signupError:(NSString *)errMsg
{
    NSLog(@"Error:%@", errMsg);
    [error setText:errMsg];
}
- (IBAction)login:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate login];
}

- (IBAction)signup:(id)sender
{
    [error setText:@""];
    
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
    NSString *signupURL = [NSString stringWithFormat:@"%@/users", [delegate domainURL]];
    
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
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *errors){
                               
                               
                               // Manage the response here.
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);
                               
                               if (!data) {
                                   [self signupError:@"Unknown error, please try again."];
                                   return;
                               }

                               
                               NSMutableDictionary *json1 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errors];

                               if ( [json1 objectForKey:@"errors"] != nil ) {
                                   
                                   NSMutableDictionary *errorsDictionary = [json1 objectForKey:@"errors"];
                                   
                                   NSArray *emailErrors = [errorsDictionary objectForKey:@"email"];
                                   if (emailErrors) {
                                       [self signupError:[NSString stringWithFormat:@"Email: %@",[emailErrors objectAtIndex:0]]];
                                   } else {
                                       [self signupError:@"Unknown Error"];
                                   }
                                   return;
                               }
                               
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
