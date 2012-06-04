//
//  TPAppDelegate.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPAppDelegate.h"
#import "TPUser.h"
#import "TPLoginViewController.h"
#import "TPSignupViewController.h"
#import "TPChatViewController.h"
#import "TPInfoViewController.h"
#import "SRWebSocket.h"
#import "TPReconnectingViewController.h"
#import "TPFindingMatchViewController.h"

@implementation TPAppDelegate

@synthesize window = _window;
@synthesize user;
@synthesize authToken;
@synthesize webSocket;
@synthesize domainURL;
@synthesize socketURL;

@synthesize deviceTok;

- (void)refreshIVC
{
    [ivc setNewPartner:[user partnerUsername]];
    [ivc setNewRS];
}

- (BOOL)hasPartner
{
    return hasPartner;
}

- (void)setHasPartner:(BOOL)hp
{
    hasPartner = hp;
}

- (void)clearUser
{
    [self setUser:nil];
    [cvc setUser:nil];
}
    
- (void)receiveMsg:(NSString *)text
{
    [cvc receiveNewEntry:text date:[[NSDate alloc] init]];
}

- (void)homeClean
{
    [[self window] setRootViewController:tbc];
}

- (void)home
{
    NSLog(@"HOME");
    [[self window] setRootViewController:tbc];
    
    [cvc setUser:[self user]];
    [cvc loggedIn];
}

- (void)signup
{
    NSLog(@"Signing Up");
    [[self window] setRootViewController:svc];
}

- (void)login
{
    [lvc setSignedIn:NO];
    // ON login we assume we have a partner
    [self setHasPartner:YES];
    
    if ([webSocket readyState] == SR_OPEN ) {
        [webSocket close];
        webSocket = nil;
    }
    
    [[self window] setRootViewController:lvc];
    NSLog(@"Logging In");
}

- (void)disconnected
{
    [[self window] setRootViewController:rvc];
}

- (void)searchingMatch
{
    if ([[self window] rootViewController] != fmvc) {
        NSLog(@"Searching For Match");
        [[self window] setRootViewController:fmvc];
    }
}

- (void)loginWithEmail:(NSString *)e password:(NSString *)p
{
    [lvc loginWithEmail:e password:p];
}

- (BOOL)loginOrSignup
{    
    return ![lvc signedIn];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    domainURL = @"http://184.169.134.227:3000";
    socketURL = @"ws://184.169.134.227:8000";
    
    hasPartner = YES;
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];	

    [self window].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil]; 
    lvc = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    svc = [storyboard instantiateViewControllerWithIdentifier:@"SignupView"];
    rvc = [[TPReconnectingViewController alloc] init];
    fmvc = [[TPFindingMatchViewController alloc] init];

    
    tbc = (UITabBarController *) [[self window] rootViewController];
    
    cvc = [[tbc viewControllers] objectAtIndex:0];
    ivc = [[tbc viewControllers] objectAtIndex:1];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:ivc];

    
    
    if (!user) {
        NSLog(@"STARTING UP");
        [self login];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ( [[self webSocket] readyState] == SR_OPEN) {
        [self webSocket].delegate = nil;
        [[self webSocket] close];
        NSLog(@"CLOSED WEB SOCKET");
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([self user]) {
        if (hasPartner) {
            [self home];  
        }
        [lvc startWebSocketWithAuthToken:[self authToken]];
        
        
    }    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    
    NSString *tok = [deviceToken description];
    
    tok = [tok stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tok = [tok stringByReplacingOccurrencesOfString:@" " withString:@""]; 
    
    NSLog(@"deviceToken: %@", tok);

    [self setDeviceTok:tok];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{ 
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@", str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    id alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    NSLog(@"Notification: %@", alert);
    
    if (alert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notification" 
                                                            message:[NSString stringWithFormat:@"%@", alert]
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

        
        [alertView show];
    }
}

@end
