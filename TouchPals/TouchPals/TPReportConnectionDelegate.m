//
//  TPReportConnectionDelegate.m
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPReportConnectionDelegate.h"

@implementation TPReportConnectionDelegate

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reported!" 
                                                    message:@"Partner reported. Thank you for making this a safer place." 
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
