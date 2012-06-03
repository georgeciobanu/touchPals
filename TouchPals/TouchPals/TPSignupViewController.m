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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// every response could mean a redirect
	receivedData = nil;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (!receivedData)
	{
		receivedData = [[NSMutableData alloc] initWithData:data];
	}
	else
	{
		[receivedData appendData:data];
	}
}

// all worked
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *str = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", str);
    
    
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSData *data = receivedData;
    if (!data) {
        [self signupError:@"Unknown error, please try again."];
        return;
    }
    
    NSMutableDictionary *json1 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if ([json1 objectForKey:@"error"]) {
        NSString *errorMsg = [json1 objectForKey:@"error"];
        
        [self signupError:errorMsg];
        return;
    }
    
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
    
    [appDelegate loginWithEmail:[email text] password:[password text]];
               
    
}

// and error occured
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)errors
{
	NSLog(@"Error retrieving data, %@", [errors localizedDescription]);
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod
			isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod
		 isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		// we only trust our own domain
		if ([challenge.protectionSpace.host isEqualToString:@"184.169.134.227"])
		{
			NSURLCredential *credential =
            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
		}
	}
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
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
    
    [NSURLConnection connectionWithRequest:signupRequest delegate:self];    
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
