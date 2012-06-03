//
//  TPFindingMatchViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-26.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPFindingMatchViewController.h"
#import "TPAppDelegate.h"
#import "TPUserInfoConnectionDelegate.h"
#import "TPUser.h"

@implementation TPFindingMatchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkConnection];
}

- (void)checkConnection
{    
    NSLog(@"CHECK CONNECTION");
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
    if ([appDelegate hasPartner]) {
        NSLog(@"PARTNER FOUND");
        [appDelegate refreshIVC];
        return;
    }
    
    if ([[appDelegate window] rootViewController] != self) {
        [appDelegate searchingMatch];
    }
        
    if ([appDelegate loginOrSignup])
        return;
    
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

    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkConnection) userInfo:nil repeats:NO];
}

- (IBAction)logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate login];
}
@end
