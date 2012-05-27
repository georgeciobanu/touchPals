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

@implementation TPLoginViewController

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
        //TODO: handle divorce
        [[appDelegate user] setPartnerUsername:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Divorce" 
                                                        message:@"Your partner got a divorce..." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [appDelegate searchingMatch];
    } else if( [@"found_match" isEqualToString:cmd]) {
        NSString *newPartner = [json objectForKey:@"partner_name"];

        [[appDelegate user] setPartnerUsername:newPartner];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wedding" 
                                                        message:@"The matchmaker found someone for you!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [appDelegate home];
    }
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"STOP ANIMATION");
    [activityIndicator stopAnimating];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [webSocket send:[appDelegate authToken]];
    
    [appDelegate homeClean];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed, code:%d, reason:%@", code, reason);
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reconnectSocket) userInfo:nil repeats:NO];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate disconnected];
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
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000"]]];
    
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
    
    [appDelegate setWebSocket:_webSocket];
}



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
                               
                               SRWebSocket *_webSocket;
                               _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8000"]]];
                               _webSocket.delegate = self;
                               
                               self.title = @"Opening Connection...";
                               [_webSocket open];
                               
                               [appDelegate setWebSocket:_webSocket];
                               
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
                               
                               NSString *pu = [json1 objectForKey:@"partner_username"];
                               
                               if (pu == (NSString *)[NSNull null])
                                   pu = [NSString stringWithFormat:@"Anonymous"];

                               [appDelegate setUser:[[TPUser alloc] initWithUsername:u email:e userId:i remainingSwaps:rs partnerUsername:pu]];
                                                              
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
