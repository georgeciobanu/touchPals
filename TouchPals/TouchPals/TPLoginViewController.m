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
#import "SRWebSocket.h"
#import "TPChatEntry.h"
#import "TPReconnectingViewController.h"
#import "TPDeviceTokenConnectionDelegate.h"
#import "TPUserInfoConnectionDelegate.h"

@implementation TPLoginViewController
@synthesize signedIn;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background2.png"]];
    
    [self setSignedIn:NO];
    
}

- (void)loginError:(NSString *)errMsg
{
    [activityIndicator stopAnimating];
    NSLog(@"Error:%@", errMsg);
    [error setText:errMsg];
}

- (void)localLoadLoginInfo
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"login.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSString *e = [dict objectForKey:@"email"];
        NSString *p = [dict objectForKey:@"password"];
        
        [email setText:e];
        [password setText:p];
    }

}

- (void)localSaveLoginInfoWithEmail:(NSString *)e password:(NSString *)p
{
    NSDictionary *rootObj = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:e, p, nil] forKeys:[NSArray arrayWithObjects:@"email", @"password", nil]];
    
    NSString *errorStr;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"login.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:rootObj
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&errorStr];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"Error : %@",error);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{    
    NSString *msg = message;
    
    if ([msg length] == 0) {
        return;
    }
    
    NSError *errors;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *json = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errors];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *cmd = [json objectForKey:@"cmd"];
    
    if ([@"msg" isEqualToString:cmd]) {
        NSString *text = [json objectForKey:@"text"];
        [appDelegate receiveMsg:text];
    } else if ([@"divorce" isEqualToString:cmd]) {
        [appDelegate setHasPartner:NO];
        NSLog(@"DIVORCE SEARCHING");
        [appDelegate searchingMatch];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mathcmaker" 
                                                        message:@"The Matchmaker is hard at work to find you a new partner!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([@"partner_name_change" isEqualToString:cmd]) {
        NSString *newPartnerUsername = [json objectForKey:@"partner_name"];
        
        [[appDelegate user] setPartnerUsername:newPartnerUsername];
             
        [appDelegate home];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [activityIndicator stopAnimating];
    
    [self localLoadLoginInfo];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *auth_token = [appDelegate authToken];
    [webSocket send:auth_token];
    
    NSString *signupURL = [NSString stringWithFormat:@"%@/users/info.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    [jsonDict setObject:[appDelegate authToken] forKey:@"auth_token"];
    
    NSData *JSONBody = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:nil];
    
    usernameRequest.HTTPMethod = @"PUT";
    [usernameRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    usernameRequest.HTTPBody = JSONBody;
    
    TPUserInfoConnectionDelegate *connDelegate = [[TPUserInfoConnectionDelegate alloc] init];
    
    [NSURLConnection connectionWithRequest:usernameRequest delegate:connDelegate];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed, code:%d, reason:%@", code, reason);
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSLog(@"Skipped reconnect:%@", ([appDelegate loginOrSignup] ? @"YES" : @"NO"));
    
    if (![appDelegate loginOrSignup]) {
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reconnectSocket) userInfo:nil repeats:NO];
        
        [appDelegate disconnected];
    }
}
    
    
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)merror;
{
    NSLog(@":( Websocket Failed With Error %@", merror);
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reconnectSocket) userInfo:nil repeats:NO];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate disconnected];

}

- (void)reconnectSocket;
{
    NSLog(@"reconnect");

    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate webSocket].delegate = nil;
    [[appDelegate webSocket] close];

    SRWebSocket *_webSocket;
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[appDelegate socketURL]]]];
    
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
    
    [appDelegate setWebSocket:_webSocket];
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
        [self loginError:@"Unknown error, please try again."];
        return;
    }
    
    
    NSMutableDictionary *json1 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if ( [json1 objectForKey:@"error"] != nil ) {
        NSString *err = [json1 objectForKey:@"error"];
        if ([err isEqualToString:@"You need to sign in or sign up before continuing."]) {
            err = [NSString stringWithFormat:@"Unknown error, please try again."];
        }
        [self loginError:err];
        return;
    }
    
    NSString *auth_token = [(NSMutableDictionary *)[json1 objectForKey:@"session"] objectForKey:@"auth_token"];
    
    if (auth_token == nil) {
        [self loginError:@"Server error, please try again."];
        return;
    }
    
    NSLog(@"SET SIGNED IN");
    [self setSignedIn:YES];    
    
    [appDelegate setAuthToken:auth_token];
    
    [self startWebSocketWithAuthToken:auth_token];
    
    NSMutableDictionary *json2 = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    
    NSMutableDictionary *userJSON = (NSMutableDictionary *)[json2 objectForKey:@"user"];
    
    NSString *e = [userJSON objectForKey:@"email"];
    NSString *u = [userJSON objectForKey:@"username"];
    
    if (u == (NSString *)[NSNull null])
        u = [NSString stringWithFormat:@"Anonymous"];
    
    
    NSInteger i = [[userJSON objectForKey:@"id"] intValue];
    
    NSInteger rs = [[userJSON objectForKey:@"remaining_swaps"] integerValue];
    
    NSString *pu = [json1 objectForKey:@"partner_username"];
    
    [appDelegate setUser:[[TPUser alloc] initWithUsername:u email:e userId:i remainingSwaps:rs partnerUsername:pu]];
    
    
    if ([NSNull null] != [json1 objectForKey:@"days_left"]) {
        [[appDelegate user] setDaysLeft:[[json1 objectForKey:@"days_left"] integerValue]];
    } else {
        [[appDelegate user] setDaysLeft:0];
    }
        
    NSString *signupURL = [NSString stringWithFormat:@"%@/users/update.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    [jsonDict setObject:[appDelegate authToken] forKey:@"auth_token"];
    
    if ([appDelegate deviceTok]) {
        [jsonDict setObject:[appDelegate deviceTok] forKey:@"apn_token"];
    }
    
    NSData *JSONBody = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:nil];
        
    usernameRequest.HTTPMethod = @"PUT";
    [usernameRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    usernameRequest.HTTPBody = JSONBody;
    
    TPDeviceTokenConnectionDelegate *connDelegate = [[TPDeviceTokenConnectionDelegate alloc] init];
    
    [NSURLConnection connectionWithRequest:usernameRequest delegate:connDelegate];


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

- (void)loginWithEmail:(NSString *)e password:(NSString *)p
{
    [self localSaveLoginInfoWithEmail:e password:p];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *loginURL = [NSString stringWithFormat:@"%@/sessions.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:loginURL];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"user\": {\"email\":\"%@\",\"password\":\"%@\"}}", e, p];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    loginRequest.HTTPMethod = @"POST";
    [loginRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [loginRequest addValue: @"application/json" forHTTPHeaderField:@"Accept"];
    loginRequest.HTTPBody = JSONBody;
    
    [NSURLConnection connectionWithRequest:loginRequest delegate:self];
}

- (void)startWebSocketWithAuthToken:(NSString *)authToken
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    SRWebSocket *_webSocket;
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[appDelegate socketURL]]]];
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
    
    [appDelegate setWebSocket:_webSocket];
}

- (IBAction)backgroundTapped:(id)sender 
{
    [[self view] endEditing:YES];
}


- (IBAction)login:(id)sender
{
    
    [error setText:@""];
    
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
