//
//  TPElopeConnectionDelegate.m
//  ArrangedMarriage
//
//  Created by Jonathan Cottrell on 12-06-01.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPElopeConnectionDelegate.h"
#import "TPAppDelegate.h"
#import "TPInfoViewController.h"
#import "TPUser.h"

@implementation TPElopeConnectionDelegate
@synthesize ivc;

- (id)initWithIVC:(TPInfoViewController *)infoVC
{
    self = [super init];
    self.ivc = infoVC;
    return self;
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
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@", txt);
    
    if ([txt isEqualToString:@"true"]) {
        
        
        
        [[ivc user] decrementRemainingSwaps];                                   
        
        if ([[ivc user] remainingSwaps] == 0) {
            [ [ivc remainingField] setText:[NSString stringWithFormat:@"$9.99"]];
        } else {
            [ [ivc remainingField] setText:[NSString stringWithFormat:@"%d Remaining Swaps", [[ivc user] remainingSwaps]]];
        }
        
        [[ivc user] setPartnerUsername:nil];
        [appDelegate searchingMatch];                               
    } else {
        //TODO: say it did not work
    }
    
    
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
