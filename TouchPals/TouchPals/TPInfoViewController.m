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

@implementation TPInfoViewController

@synthesize user;

- (void) logout:(id)sender
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate login];
}

- (void) serverUpdateUsername:(NSString*)u
{    
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    
    NSString *signupURL = [NSString stringWithFormat:@"http://localhost:3000/users/update.json?auth_token=%@", [appDelegate authToken]];
    
    NSURL *url = [NSURL URLWithString:signupURL];
    
    NSMutableURLRequest *usernameRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *JSONString = [NSString stringWithFormat:@"{\"username\": \"%@\" }", u];
    
    NSData *JSONBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    
    usernameRequest.HTTPMethod = @"PUT";
    [usernameRequest addValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    usernameRequest.HTTPBody = JSONBody;

    NSOperationQueue *queue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:usernameRequest 
                                       queue:queue 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               NSString *txt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                               NSLog(@"%@", txt);

                           }];

}

- (IBAction)updateUsername:(id)sender
{
    NSString *newUsername = [usernameField text];
    
    [user updateUsername:[usernameField text]];
    
    [self serverUpdateUsername:newUsername];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction Failed");
        
        //TODO: display alert
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)elope
{
    TPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *elopeURL = [NSString stringWithFormat:@"http://localhost:3000/users/elope?auth_token=%@", [appDelegate authToken]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:elopeURL]];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        NSLog(@"Error with server connection");
        return;
    }
    
    [user decrementRemainingSwaps];
    
    if ([user remainingSwaps] == 0) {
        [remainingField setText:[NSString stringWithFormat:@"$9.99"]];
    } else {
        [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    }
    
    [user setPartnerUsername:nil];
    
    [appDelegate searchingMatch];

    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction successful");
    
    [user setRemainingSwaps:([user remainingSwaps]+1)];
    
    [self elope];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.

    NSLog(@"Transaction successful");

    [user setRemainingSwaps:([user remainingSwaps]+1)];
    
    [self elope];    
    
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
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}


- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                 [NSSet setWithObject:@"elope_001"]];
    request.delegate = self;
    [request start];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (alertView == buyAlert && buttonIndex == 1) {
        
        NSLog(@"PURCHASING");
        
        SKProduct *selectedProduct = elopeProduct;
        
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    } else if (alertView == elopeAlert && buttonIndex == 1) {
        [self elope];
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
                                              otherButtonTitles:[NSString stringWithFormat:@"$%d", [elopeProduct price]], nil];
        [buyAlert show];

        
    }
    
    // Populate your UI from the products list.
    // Save a reference to the products list.
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
    
    [remainingField setText:[NSString stringWithFormat:@"%d Remaining Swaps", [user remainingSwaps]]];
    [partnerNameField setText:[NSString stringWithFormat:@"Partner: %@", [user partnerUsername]]];
    [usernameField setText:[user username]];    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
