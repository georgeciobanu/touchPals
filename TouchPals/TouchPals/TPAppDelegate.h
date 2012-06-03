//
//  TPAppDelegate.h
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class TPUser;
@class TPLoginViewController;
@class TPSignupViewController;
@class SRWebSocket;
@class TPChatViewController;
@class TPInfoViewController;
@class TPReconnectingViewController;
@class TPFindingMatchViewController;

@interface TPAppDelegate : UIResponder <UIApplicationDelegate>
{
    UITabBarController *tbc;
    TPLoginViewController *lvc;
    TPSignupViewController *svc;
    TPChatViewController *cvc;
    TPInfoViewController *ivc;
    TPReconnectingViewController *rvc;
    TPFindingMatchViewController *fmvc;
    
    BOOL hasPartner;
}

@property (nonatomic) NSString *domainURL;
@property (nonatomic) NSString *socketURL;

@property (nonatomic) SRWebSocket *webSocket;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TPUser *user;
@property (strong, nonatomic) NSString *authToken;

@property (strong, nonatomic) NSString *deviceTok;


- (void)home;
- (void)homeClean;
- (void)signup;
- (void)login;
- (void)receiveMsg:(NSString *)text;
- (void)disconnected;
- (void)searchingMatch;
- (void)clearUser;

- (BOOL)hasPartner;
- (void)setHasPartner:(BOOL)hp;

- (void)loginWithEmail:(NSString *)e password:(NSString *)p;

- (void)refreshIVC;

- (BOOL)loginOrSignup;

@end
