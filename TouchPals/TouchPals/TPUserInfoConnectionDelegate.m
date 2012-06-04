//
//  TPUserInfoConnectionDelegate.m
//  ChatAffair
//
//  Created by Jonathan Cottrell on 12-06-02.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPUserInfoConnectionDelegate.h"
#import "TPAppDelegate.h"
#import "TPUser.h"

@implementation TPUserInfoConnectionDelegate

// all worked
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
	NSString *str = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	NSLog(@"WEBSOCKET CONNECTED:%@", str);
    
    NSData *data = receivedData;
    
    if (!data) {
        return;
    }
    
    NSMutableDictionary *json1 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSMutableDictionary *userJSON = (NSMutableDictionary *)[json1 objectForKey:@"user"];

    NSObject *partnerId = [userJSON objectForKey:@"partner_id"];
    
    if ([NSNull null] == partnerId && [appDelegate hasPartner]) {
        NSLog(@"USERINFO searching");
        [appDelegate searchingMatch];
        [appDelegate setHasPartner:NO];
    } else if (![appDelegate hasPartner] && [NSNull null] != partnerId) {
        NSString *partnerName = [json1 objectForKey:@"partner_username"];
        
        NSInteger rs = [[json1 objectForKey:@"remaining_swaps"] integerValue];
        
        
        if ([NSNull null] != [json1 objectForKey:@"days_left"]) {
            [[appDelegate user] setDaysLeft:[[json1 objectForKey:@"days_left"] integerValue]];
        } else {
            [[appDelegate user] setDaysLeft:0];
        }
        
        [[appDelegate user] setPartnerUsername:partnerName];
        NSLog(@"New partner:%@", partnerName);
        
        [[appDelegate user] setRemainingSwaps:rs];
        [appDelegate setHasPartner:YES];
        [appDelegate refreshIVC];
        [appDelegate home];
    } else if ([appDelegate hasPartner]) {
        [appDelegate home];
    }
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
