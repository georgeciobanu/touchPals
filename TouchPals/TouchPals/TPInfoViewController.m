//
//  TPSecondViewController.m
//  TouchPals
//
//  Created by Jonathan Cottrell on 12-05-21.
//  Copyright (c) 2012 McGill University. All rights reserved.
//

#import "TPInfoViewController.h"
#import "TPUser.h"
#import "TPAppDelegate.h"
#import "TPElopeConnectionDelegate.h"
#import "TPUsernameConnectionDelegate.h"
#import "TPInviteConnectionDelegate.h"
#import "TPReportConnectionDelegate.h"

@implementation TPInfoViewController
@synthesize remainingField;
@synthesize user;

- (void) logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate login];
}

- (IBAction)reportPartner:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *reportURL = [NSString stringWithFormat:@"%@/reports.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:reportURL];
    
    NSMutableURLRequest *reportRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *jsonStr = [NSString stringWithFormat:@"{\"auth_token\":\"%@\"}", [appDelegate authToken]];
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    reportRequest.HTTPMethod = @"POST";
    [reportRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    reportRequest.HTTPBody = jsonData;
    
    TPReportConnectionDelegate *connDelegate = [[TPReportConnectionDelegate alloc] init];
    
    [NSURLConnection connectionWithRequest:reportRequest delegate:connDelegate];        

}

- (IBAction)inviteFriend:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *email = [inviteEmailField text];
    
    if ([email length] > 0) {
        NSString *inviteURL = [NSString stringWithFormat:@"%@/invites.json", [appDelegate domainURL]];
        
        NSURL *url = [NSURL URLWithString:inviteURL];
        
        NSMutableURLRequest *inviteRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSString *jsonStr = [NSString stringWithFormat:@"{\"email\":\"%@\", \"auth_token\":\"%@\"}", email, [appDelegate authToken]];
        
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        
        inviteRequest.HTTPMethod = @"POST";
        [inviteRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        inviteRequest.HTTPBody = jsonData;
        
        TPInviteConnectionDelegate *connDelegate = [[TPInviteConnectionDelegate alloc] initWithIVC:self];
        
        [NSURLConnection connectionWithRequest:inviteRequest delegate:connDelegate];        
    }
}

- (void) serverUpdateUsername:(NSString*)u
{    
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    
    NSString *signupURL = [NSString stringWithFormat:@"%@/users/update.json", [appDelegate domainURL]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"username\": \"%@\", \"auth_token\":\"%@\" }", u, [appDelegate authToken]];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    usernameRequest.HTTPMethod = @"PUT";
    [usernameRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    usernameRequest.HTTPBody = JSONBody;

    
    TPUsernameConnectionDelegate *connDelegate = [[TPUsernameConnectionDelegate alloc] initWithIVC:self];
    
    [NSURLConnection connectionWithRequest:usernameRequest delegate:connDelegate];
}

- (IBAction)updateUsername:(id)sender
{
    NSString *newUsername = [usernameField text];
    
    [user updateUsername:[usernameField text]];
    
    [self serverUpdateUsername:newUsername];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"TRANSACTION FAILED");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction Failed");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)elopeWithReceipt:(NSData *)receipt
{
    NSLog(@"ELOPING");
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *elopeURL = [NSString stringWithFormat:@"%@/users/elope", [appDelegate domainURL], [appDelegate authToken]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:elopeURL]];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"auth_token\":\"%@\"}", [appDelegate authToken]];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];

    
    [request setHTTPMethod:@"PUT"];
    [request addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue: @"application/json" forHTTPHeaderField:@"Accept"];

    request.HTTPBody = JSONBody;
    
    
    if (!receipt) {
        receipt = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        receipt = [[NSString stringWithFormat:@"{%@}"] dataUsingEncoding:NSUTF8StringEncoding];
    }
        
    request.HTTPBody = receipt;
    
    NSLog(@"Receipt JSON:%@", request.HTTPBody);
    
    TPElopeConnectionDelegate *connDelegate = [[TPElopeConnectionDelegate alloc] initWithIVC:self];
    
    [NSURLConnection connectionWithRequest:request delegate:connDelegate];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction successfully restored -- nothing else done");
    
    [user setRemainingSwaps:([user remainingSwaps]+1)];
    [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    
    NSData *receipt = [transaction transactionReceipt];
    [self elopeWithReceipt:receipt];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.

    NSLog(@"Transaction successful");

    [user setRemainingSwaps:([user remainingSwaps]+1)];
    [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    
    NSData *receipt = [transaction transactionReceipt];
    [self elopeWithReceipt:receipt];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased");
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Failed");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored");
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}


- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObject:@"elope_02"]];
    request.delegate = self;
    [request start];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (alertView == buyAlert && buttonIndex == 1) {
                
        SKProduct *selectedProduct = elopeProduct;
        
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    } else if (alertView == elopeAlert && buttonIndex == 1) {
        [self elopeWithReceipt:nil];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    
    if ([myProducts count] > 0) {
        elopeProduct = [myProducts objectAtIndex:0];
                
        NSLog(@"%@",[elopeProduct description]);
        
        buyAlert = [[UIAlertView alloc] initWithTitle:@"Elope" 
                                                        message:@"Are you sure you want to elope?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:[NSString stringWithFormat:@"OK"], nil];
        [buyAlert show];
    } else {
        NSLog(@"NO ELOPING PRODUCT FOUND");
    }    
}


- (IBAction)getNewPartner:(id)sender
{    
    if ([user remainingSwaps] > 0) {        
        elopeAlert = [[UIAlertView alloc] initWithTitle:@"Elope" 
                                                        message:@"Are you sure you want to elope?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        [elopeAlert show];

        
    } else {
        if ([SKPaymentQueue canMakePayments]) {
            
            elopeProduct = nil;
            [self requestProductData];
            
                        
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments Unauthorized" 
                                                            message:@"In-app purchases are not authorized!" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }
        
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
    
    if ([appDelegate user] == nil) {
        [appDelegate login];
        return;
    }
    
    [self setUser:[appDelegate user]];
    
    if ([user remainingSwaps] == 0) {
        [remainingField setText:[NSString stringWithFormat:@"$9.99"]];
    } else {
        [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    }
    [partnerNameField setText:[NSString stringWithFormat:@"Partner: %@", [user partnerUsername]]];
    [usernameField setText:[user username]];    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

}

- (void)viewDidUnload {
    inviteEmailField = nil;
    [super viewDidUnload];
}
@end
