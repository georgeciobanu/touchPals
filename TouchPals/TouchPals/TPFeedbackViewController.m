//
//  TPFeedbackViewController.m
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPFeedbackViewController.h"
#import "TPAppDelegate.h"

@implementation TPFeedbackViewController

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender
{
    
    NSString *msg = [textView text];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *reportURL = [NSString stringWithFormat:@"%@/feedbacks.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:reportURL];
    
    NSMutableURLRequest *reportRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[appDelegate authToken] forKey:@"auth_token"];

    [dictionary setObject:msg forKey:@"text"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary 
                                    options:NSJSONWritingPrettyPrinted error:nil];
    
    reportRequest.HTTPMethod = @"POST";
    [reportRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reportRequest.HTTPBody = jsonData;
    
    [NSURLConnection connectionWithRequest:reportRequest delegate:self];        

    
    [self dismissModalViewControllerAnimated:YES];
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feedback Sent!" 
                                                    message:@"Thank you for sending us feedback!" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
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

@end
