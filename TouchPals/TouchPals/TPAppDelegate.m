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
    
    [[self window] setRootViewController:lvc];
    NSLog(@"Logging In");
}

- (void)disconnected
{
    [[self window] setRootViewController:rvc];
}

- (void)searchingMatch
{
    NSLog(@"Searching For Match");
    [[self window] setRootViewController:fmvc];
}

- (void)loginWithEmail:(NSString *)e password:(NSString *)p
{
    [lvc loginWithEmail:e password:p];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    
    domainURL = @"http://localhost:3000";
    socketURL = @"http://localhost:8000";

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil]; 
    lvc = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    svc = [storyboard instantiateViewControllerWithIdentifier:@"SignupView"];
    ivc = [storyboard instantiateViewControllerWithIdentifier:@"InfoView"];
    rvc = [[TPReconnectingViewController alloc] init];
    fmvc = [[TPFindingMatchViewController alloc] init];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:ivc];
    
    tbc = (UITabBarController *) [[self window] rootViewController];
    
    cvc = [[tbc viewControllers] objectAtIndex:0];
    
    if (!user) {
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
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([self user]) {
        [self home];   
    }
    
    /*
    if ( [[self webSocket] readyState] != SR_OPEN && [self user] != nil) {
        [lvc reconnectSocket];
    }
    
    if ([user partnerUsername] == nil) {
        [self searchingMatch];
    }
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
