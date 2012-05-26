//
//  TPAppDelegate.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPUser;
@class TPLoginViewController;
@class TPSignupViewController;
@class SRWebSocket;
@class TPChatViewController;
@class TPReconnectingViewController;
@class TPFindingMatchViewController;

@interface TPAppDelegate : UIResponder <UIApplicationDelegate>
{
    UITabBarController *tbc;
    TPLoginViewController *lvc;
    TPSignupViewController *svc;
    TPChatViewController *cvc;
    TPReconnectingViewController *rvc;
    TPFindingMatchViewController *fmvc;
}


@property (nonatomic) SRWebSocket *webSocket;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TPUser *user;
@property (strong, nonatomic) NSString *authToken;

- (void)home;
- (void)homeClean;
- (void)signup;
- (void)login;
- (void)receiveMsg:(NSString *)text;
- (void)disconnected;
- (void)searchingMatch;
- (void)clearUser;

- (void)loginWithEmail:(NSString *)e password:(NSString *)p;

@end
